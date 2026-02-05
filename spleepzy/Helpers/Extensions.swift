//
//  Extensions.swift
//  GBV
//
//  Created by Khaled on 15/08/2024.
//

import UIKit

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        let windowScenes = connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let activeScene = windowScenes
            .filter { $0.activationState == .foregroundActive }

        let firstActiveScene = activeScene.first

        let keyWindow = firstActiveScene?.keyWindow
        
        return keyWindow
    }

    var rootViewController: UIViewController {
        let viewController = firstKeyWindow?.rootViewController
        return viewController!
    }
    
}

// MARK: - String

extension String {
    var withPlaceholder: String {
        self.isEmpty ? "-" : self
    }
    var withNA: String {
        self.isEmpty ? "N/A".localized : self
    }
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
    var withPlaceholder: String {
        self.isNilOrEmpty ? "-" : self!
    }
    var withNA: String {
        self.isNilOrEmpty ? "N/A".localized : self!
    }
    var trimmed: String {
        self?.trimmed ?? ""
    }
}


// MARK: - NSAttributedString

extension NSAttributedString {
    var isEmpty: Bool {
        string.count == 0
    }
    var withPlaceholder: NSAttributedString {
        self.isEmpty ? NSAttributedString(string: "-") : self
    }
    var withNA: NSAttributedString {
        self.isEmpty ? NSAttributedString(string: "N/A".localized) : self
    }
    var trimmed: NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.utf16.description.rangeOfCharacter(from: invertedSet)
        let endRange = string.utf16.description.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return self //NSAttributedString(string: string)
        }
        
        let location = string.utf16.distance(from: string.startIndex, to: startLocation) - 1
        let length = string.utf16.distance(from: startLocation, to: endLocation) + 2
        let range = NSRange(location: location, length: length)
        return attributedSubstring(from: range)
    }

}

extension Optional where Wrapped == NSAttributedString {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}


// MARK: - Optional
extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}

// MARK: - Optional Bool

extension Bool {
    var isTrue: Bool {
        self == true
    }
    var isFalse: Bool {
        self == false
    }
}

extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        self == true
    }
    var isFalseOrNil: Bool {
        !isTrue
    }
}

extension String {
    // TODO: enhance this function
    func onlyInteger() -> String {
        let sign = trimmed.starts(with: "-") ? "-" : ""
        let allowed = CharacterSet.decimalDigits
        let filteredUnicodeScalars = unicodeScalars.filter { allowed.contains($0) }
        return sign + String(String.UnicodeScalarView(filteredUnicodeScalars))
    }
}

// MARK: - NumberFormatter

extension NumberFormatter {
    static let floatFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return formatter
    }()
    static let float2Formatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return formatter
    }()
    static let floatCurrencyFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Numeric {
    var formattedString: String {
        NumberFormatter.floatFormatter.string(for: self) ?? "\(self)"
    }
    var formatted2String: String {
        NumberFormatter.float2Formatter.string(for: self) ?? "\(self)"
    }
    var formattedCurrencyString: String {
        NumberFormatter.floatCurrencyFormatter.string(for: self) ?? "\(self)"
    }
    var formattedPercentageString: String {
        (NumberFormatter.floatFormatter.string(for: self) ?? "\(self)") + "%"
    }
    var planeString: String {
        "\(self)"
    }
}

// MARK: - URL

extension String {
    var url: URL? {
        var url: URL? = nil
        url = URL(string: self)
        if url == nil {
            let encodeString =  self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let encodeString = encodeString {
                url = URL(string: encodeString)
            }
        }
        
        if let _url = url, _url.scheme == nil {
            var components = URLComponents(url: _url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            url = components?.url
        }
        
        return url
    }
    
    func url(baseURL: URL) -> URL? {
        var url: URL? = nil
        url = URL(string: self, relativeTo: baseURL)
        if url == nil {
            let encodeString =  self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let encodeString = encodeString {
                url = URL(string: encodeString, relativeTo: baseURL)
            }
        }
        
        if let _url = url, _url.scheme == nil {
            var components = URLComponents(url: _url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            url = components?.url
        }
        
        return url
    }

}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}


extension MutableCollection {
    subscript (safe index: Index?) -> Iterator.Element? {
        get {
            guard let index = index, startIndex <= index, index < endIndex else { return nil }
            return self[index]
        }
        set(newValue) {
            guard let index = index, startIndex <= index, index < endIndex else { print("Index out of range."); return }
            guard let newValue = newValue else { print("Cannot remove out of bounds items"); return }
            self[index] = newValue
        }
    }
}

extension Data {
    func prettyPrint() {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }

}

/*
 Local
 */
extension DateFormatter {
    static let localDateFormatter: DateFormatter! = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM, yyyy"
        formatter.dateFormat = "dd MMM, yyyy"
        //formatter.dateStyle = .medium
        //formatter.timeStyle = .none
        //formatter.locale = Locale(identifier: "SA_ar")
        return formatter
    }()
    
    static let localTimeFormatter: DateFormatter! = {
        let formatter = DateFormatter()
        // formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let localDateTimeFormatter: DateFormatter! = {
        let formatter = DateFormatter()
        // formatter.dateFormat = "EEE, dd MMM yyyy, HH:mm"
        formatter.dateFormat = "EEE, dd MMM yyyy, HH:mm"
        // formatter.dateStyle = .medium
        // formatter.timeStyle = .short
        
        return formatter
    }()
    
    // التاريخ الهجري بصيغة: "Jumada | 19, 1446 AH"
    static let islamicDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // التقويم الهجري الرسمي (Umm al-Qura)
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        // اللغة الإنجليزية لاسم الشهر
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM | dd, yyyy 'AH'"
        return formatter
    }()
    

#warning("TODO: ")
    // MARK: Server
    static var serverDateFormatter: DateFormatter { // computed
        let formatter = DateFormatter()
        // 2024-07-30
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
#warning("TODO: ")
    static var serverTimeFormatter: DateFormatter { // computed
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // Check
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
#warning("TODO: ")
    static var serverDateTimeFormatter: DateFormatter { // computed
        let formatter = DateFormatter()
        // 2024-07-30 09:38 AM
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
}


extension Date {
    func formattedDate() -> String {
        return DateFormatter.localDateFormatter.string(from: self)
    }
    
    func formattedTime() -> String {
        return DateFormatter.localTimeFormatter.string(from: self)
    }
    
    func formattedDateTime() -> String {
        return DateFormatter.localDateTimeFormatter.string(from: self)
    }
    
    func formatted(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "US")
        return formatter.string(from: self)
    }
    
    
    func formattedServerDate() -> String {
        return DateFormatter.serverDateFormatter.string(from: self)
    }
    
    func formattedServerTime() -> String {
        return DateFormatter.serverTimeFormatter.string(from: self)
    }
    
    func formattedServerDateTime() -> String {
        return DateFormatter.serverDateTimeFormatter.string(from: self)
    }
    

}


extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        #warning("TODO: set timeAgo local")
        //formatter.locale = Language.current.local
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}

extension Date {
    func get(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// HTML
extension String {
    var htmlToNSAttributed: NSAttributedString {
        guard let data = data(using: .unicode) else { return NSAttributedString(string: self) }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.unicode.rawValue
                ],
                documentAttributes: nil
            )
            // .trimmed
        } catch {
            return NSAttributedString(string: self).trimmed
        }
    }
    
    var trimHTMLTags: String {
        // htmlToNSAttributed.string
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var htmlToAttributed: AttributedString {
        do {
            if Thread.current.isMainThread {
                return try AttributedString(htmlToNSAttributed, including: \.swiftUI)
            } else {
                return try DispatchQueue.main.sync {
                    return try AttributedString(htmlToNSAttributed, including: \.swiftUI)
                }
            }
        } catch {
            return AttributedString(stringLiteral: self)
        }
    }
    
    var htmlToAttributedUIKit: AttributedString {
        do {
            if Thread.current.isMainThread {
                return try AttributedString(htmlToNSAttributed, including: \.uiKit)
            } else {
                return try DispatchQueue.main.sync {
                    return try AttributedString(htmlToNSAttributed, including: \.uiKit)
                }
            }
        } catch {
            return AttributedString(stringLiteral: self)
        }
    }

}

extension String {
    /// Validates if the string is a valid email address.
    func isValidEmail() -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

// Extension for Encodable to convert an object to Base64
extension Encodable {
    func toBase64() -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return jsonData.base64EncodedString()
        } catch {
            print("Error encoding object to Base64: \(error)")
            return nil
        }
    }
}

// Extension for Decodable to decode a Base64 string into an object
extension Decodable {
    static func fromBase64(_ base64String: String) -> Self? {
        guard let data = Data(base64Encoded: base64String) else {
            print("Invalid Base64 string")
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("Error decoding Base64 string to object: \(error)")
            return nil
        }
    }
}
