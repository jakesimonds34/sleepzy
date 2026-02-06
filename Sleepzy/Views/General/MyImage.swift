//
//  MyImage.swift
//  DiwanV2
//
//  Created by Khaled on 15/03/2023.
//

import SwiftUI
import SDWebImageSwiftUI

enum ImageSource: Equatable {
    case asset(ImageResource?, renderingMode: Image.TemplateRenderingMode = .original)
    case system(String?, renderingMode: Image.TemplateRenderingMode = .template)
    case url(URL?, placeholder: Image, initiative: Character? = nil, renderingMode: Image.TemplateRenderingMode = .original)
    // case fontAwesome(String?)
}

struct MyImage: View {
    let source: ImageSource
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Group {
            if case let .asset(string, renderingMode) = source, let string {
                Image(string)
                    .renderingMode(renderingMode)
                    .resizable()
                    // .scaledToFit()

            } else if case let .system(string, renderingMode) = source, let string {
                Image(systemName: string)
                    .renderingMode(renderingMode)
                    .resizable()
                    .scaledToFit()

            } else if case let .url(uRL, placeholder, initiative, renderingMode) = source {
                GeometryReader { proxy in
                    let size = CGSize(
                        width: proxy.size.width * displayScale,
                        height: proxy.size.height * displayScale
                    )
                    WebImage(
                        url: uRL,
                        context: [.imageThumbnailPixelSize: size],
                        content: { $0 },
                        placeholder: {
                            if let initiative {
                                Text(String(initiative.uppercased()))
                                    .font(.system(size: 16)) //min(size.width, size.height)*0.2
                                    .multilineTextAlignment(.center)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.1)
                                    .padding(min(size.width, size.height) * 0.3)
                                    .frame(width: size.width, height: size.height, alignment: .center)
                            } else {
                                placeholder.resizable()
                                // .overlay {
                                //     ProgressView()
                                // }
                            }
                        }
                    )
                    .resizable()
                    .renderingMode(renderingMode)
                    // .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }

                // } else if case let .fontAwesome(string) = source, let string {
                //     let name = nameFor(fontAwesomeName: string)
                //     GeometryReader { proxy in
                //         FAText(
                //             iconName: name.name,
                //             size: min(proxy.size.width, proxy.size.height),
                //             style: name.style
                //         )
                //         .minimumScaleFactor(0.1)
                //         .lineLimit(1)
                //         .frame(width: proxy.size.width, height: proxy.size.height)
                //     }

            } else {
                EmptyView()

            }
        }
    }
}


#Preview {
    let width: CGFloat = 100
    let height: CGFloat = 120
    let clipShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    let background = Color.white

    ScrollView {
        VStack(alignment: .center, spacing: 8) {
            MyImage(source: .asset(
                .loadingIndicator)
            )
            .frame(width: width, height: height)
            .background(background)
            .clipShape(clipShape)

            MyImage(source: .asset(
                .loadingIndicator,
                renderingMode: .template)
            )
            .frame(width: width, height: height)
            .background(background)
            .clipShape(clipShape)

            MyImage(source: .system(
                "square.and.arrow.up.circle")
            )
            .frame(width: width, height: height)
            .background(background)
            .clipShape(clipShape)

            MyImage(source: .url(
                URL(string: "https://picsum.photos/200/300"),
                placeholder: Image(systemName: "square.and.arrow.up.fill"))
            )
            .frame(width: width, height: height)
            .background(background)
            .clipShape(clipShape)
        }
    }
    .foregroundColor(.red)
}
