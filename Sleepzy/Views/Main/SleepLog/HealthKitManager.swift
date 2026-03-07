import Foundation
import HealthKit
import Combine
import os.log

// MARK: - HealthKitManager
// Requests authorization and fetches sleep data from Apple Health

@MainActor
final class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private let logger = Logger(subsystem: "com.sleepzy.app", category: "HealthKit")

    @Published var isAuthorized = false
    @Published var sessions: [SleepSession] = []
    @Published var isLoading  = false
    @Published var error: String? = nil

    // HealthKit types we need
    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        // Heart rate for quality estimate (optional)
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(hr)
        }
        return types
    }()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            error = "Health data is not available on this device."
            return
        }

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            logger.info("✅ HealthKit authorized")
            await fetchSleepData(for: .weekly)
        } catch {
            self.error = "Authorization failed: \(error.localizedDescription)"
            logger.error("❌ HealthKit auth failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Sleep Data

    func fetchSleepData(for period: SleepPeriod) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        // Always fetch 2 years so offset navigation works without re-fetching
        let end   = Date()
        let start = Calendar.current.date(byAdding: .year, value: -2, to: end)!

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sort      = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        do {
            let samples = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[HKSample], Error>) in
                let query = HKSampleQuery(
                    sampleType: sleepType,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [sort]
                ) { _, result, err in
                    if let err { cont.resume(throwing: err) }
                    else       { cont.resume(returning: result ?? []) }
                }
                store.execute(query)
            }

            let categorySamples = samples.compactMap { $0 as? HKCategorySample }
            sessions = buildSessions(from: categorySamples)
            logger.info("📊 Loaded \(self.sessions.count) sleep sessions")

        } catch {
            self.error = "Failed to load sleep data: \(error.localizedDescription)"
            logger.error("❌ Sleep fetch error: \(error.localizedDescription)")
            // Fall back to demo data so the UI is never empty
            sessions = Self.demoSessions()
        }

        // If no real data, show demo data
        if sessions.isEmpty {
            sessions = Self.demoSessions()
        }
    }

    // MARK: - Build Sessions from HKCategorySample

    private func buildSessions(from samples: [HKCategorySample]) -> [SleepSession] {
        let cal = Calendar.current

        // ✅ Fix 1: استبعاد inBed — ليس نوماً حقيقياً
        let sleepSamples = samples.filter {
            HKCategoryValueSleepAnalysis(rawValue: $0.value) != .inBed
        }

        // ✅ Fix 2: إزالة التداخل — إذا تداخل sample مع سابقه نقصّه
        let sorted = sleepSamples.sorted { $0.startDate < $1.startDate }
        var deduped: [HKCategorySample] = []
        for s in sorted {
            if let last = deduped.last, s.startDate < last.endDate {
                // تداخل — تجاهل هذا الـ sample إذا كان مغطى بالكامل
                if s.endDate <= last.endDate { continue }
            }
            deduped.append(s)
        }

        // ✅ Fix 3: التجميع بـ "noon rule"
        // كل sample ينتمي للـ night التي تبدأ قبل الظهر التالي
        // أي: إذا startDate بعد 12 PM → ينتمي لليوم نفسه (بداية الليلة)
        //     إذا startDate قبل 12 PM → ينتمي لليوم السابق (نهاية الليلة)
        var grouped: [Date: [HKCategorySample]] = [:]
        for s in deduped {
            let hour = cal.component(.hour, from: s.startDate)
            let nightStart: Date
            if hour < 12 {
                // نوم صباحي → ينتمي لليلة الأمس
                let yesterday = cal.date(byAdding: .day, value: -1, to: s.startDate)!
                nightStart = cal.startOfDay(for: yesterday)
            } else {
                nightStart = cal.startOfDay(for: s.startDate)
            }
            grouped[nightStart, default: []].append(s)
        }

        var result: [SleepSession] = []

        for (day, nightSamples) in grouped {
            guard !nightSamples.isEmpty else { continue }
            let nightSorted = nightSamples.sorted { $0.startDate < $1.startDate }

            guard let firstStart = nightSorted.first?.startDate,
                  let lastEnd   = nightSorted.last?.endDate else { continue }

            // ✅ Fix 4: تجاهل sessions أقل من 30 دقيقة (naps مزيفة)
            let totalSeconds = lastEnd.timeIntervalSince(firstStart)
            guard totalSeconds >= 1800 else { continue }

            var segments: [SleepSegment] = []
            for s in nightSorted {
                let offsetHours = s.startDate.timeIntervalSince(firstStart) / 3600
                let durHours    = s.endDate.timeIntervalSince(s.startDate) / 3600
                guard durHours > 0 else { continue }
                segments.append(SleepSegment(
                    stage: mapHKStage(s.value),
                    startHour: offsetHours,
                    durationHours: durHours
                ))
            }

            result.append(SleepSession(
                date: day,
                bedtime: firstStart,
                wakeTime: lastEnd,
                segments: segments
            ))
        }

        return result.sorted { $0.date > $1.date }
    }

    private func mapHKStage(_ value: Int) -> SleepStage {
        switch HKCategoryValueSleepAnalysis(rawValue: value) {
        case .awake:                        return .awake
        case .asleepREM:                    return .rem
        case .asleepCore:                   return .lightSleep
        case .asleepDeep:                   return .deepSleep
        case .inBed:                        return .awake  // inBed = في السرير وليس نوماً
        case .asleepUnspecified:            return .lightSleep
        default:                            return .lightSleep
        }
    }

    // MARK: - Clear Sessions (عند إيقاف Apple Health sync)
    func clearSessions() {
        sessions = []
    }

    // MARK: - Demo Data (shown when no HealthKit data available)

    static func demoSessions() -> [SleepSession] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // bedtime = ليلة daysAgo (بعد منتصف الليل أو قبله)
        // waketime = صباح نفس اليوم (daysAgo - 1)
        // المشكلة السابقة: كلاهما كانا في نفس اليوم → مدة 30 ساعة خاطئة
        func makeBed(daysAgo: Int, h: Int, m: Int) -> Date {
            // إذا النوم بعد منتصف الليل (h < 12) → نفس اليوم daysAgo
            // إذا النوم قبل منتصف الليل (h >= 22) → اليوم daysAgo + 1 (الليلة السابقة)
            let dayOffset = (h >= 22) ? -(daysAgo + 1) : -daysAgo
            let day = cal.date(byAdding: .day, value: dayOffset, to: today)!
            return cal.date(bySettingHour: h, minute: m, second: 0, of: day)!
        }

        func makeWake(daysAgo: Int, h: Int, m: Int) -> Date {
            let day = cal.date(byAdding: .day, value: -daysAgo, to: today)!
            return cal.date(bySettingHour: h, minute: m, second: 0, of: day)!
        }

        func session(daysAgo: Int,
                     bedH: Int, bedM: Int,
                     wakeH: Int, wakeM: Int,
                     segments: [SleepSegment]) -> SleepSession {
            let bed  = makeBed(daysAgo: daysAgo, h: bedH, m: bedM)
            let wake = makeWake(daysAgo: daysAgo, h: wakeH, m: wakeM)
            let dayDate = makeWake(daysAgo: daysAgo, h: 12, m: 0)
            return SleepSession(date: dayDate, bedtime: bed, wakeTime: wake, segments: segments)
        }

        // Segments واقعية تغطي ~6-7 ساعات
        let typicalSegments: [SleepSegment] = [
            SleepSegment(stage: .awake,      startHour: 0.00, durationHours: 0.20),
            SleepSegment(stage: .lightSleep, startHour: 0.20, durationHours: 0.80),
            SleepSegment(stage: .deepSleep,  startHour: 1.00, durationHours: 1.00),
            SleepSegment(stage: .rem,        startHour: 2.00, durationHours: 1.50),
            SleepSegment(stage: .lightSleep, startHour: 3.50, durationHours: 0.50),
            SleepSegment(stage: .awake,      startHour: 4.00, durationHours: 0.10),
            SleepSegment(stage: .deepSleep,  startHour: 4.10, durationHours: 0.80),
            SleepSegment(stage: .rem,        startHour: 4.90, durationHours: 1.30),
            SleepSegment(stage: .lightSleep, startHour: 6.20, durationHours: 0.50),
            SleepSegment(stage: .awake,      startHour: 6.70, durationHours: 0.10),
        ]

        let shortSegments: [SleepSegment] = [
            SleepSegment(stage: .awake,      startHour: 0.00, durationHours: 0.25),
            SleepSegment(stage: .lightSleep, startHour: 0.25, durationHours: 0.75),
            SleepSegment(stage: .deepSleep,  startHour: 1.00, durationHours: 0.80),
            SleepSegment(stage: .rem,        startHour: 1.80, durationHours: 1.20),
            SleepSegment(stage: .lightSleep, startHour: 3.00, durationHours: 0.50),
            SleepSegment(stage: .deepSleep,  startHour: 3.50, durationHours: 0.60),
            SleepSegment(stage: .rem,        startHour: 4.10, durationHours: 1.10),
            SleepSegment(stage: .lightSleep, startHour: 5.20, durationHours: 0.40),
        ]

        return [
            session(daysAgo: 0, bedH: 0, bedM: 20, wakeH: 7, wakeM: 0,  segments: typicalSegments),
            session(daysAgo: 1, bedH: 0, bedM: 20, wakeH: 6, wakeM: 40, segments: shortSegments),
            session(daysAgo: 2, bedH: 0, bedM: 20, wakeH: 7, wakeM: 0,  segments: typicalSegments),
            session(daysAgo: 3, bedH: 0, bedM: 0,  wakeH: 7, wakeM: 0,  segments: typicalSegments),
            session(daysAgo: 4, bedH: 23, bedM: 45, wakeH: 6, wakeM: 30, segments: shortSegments),
            session(daysAgo: 5, bedH: 0, bedM: 10,  wakeH: 7, wakeM: 15, segments: typicalSegments),
            session(daysAgo: 6, bedH: 23, bedM: 30, wakeH: 6, wakeM: 45, segments: shortSegments),
        ]
    }
}
