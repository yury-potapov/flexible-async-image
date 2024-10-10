import SwiftUI

extension FlexibleAsyncImageSource {
    public static func constant(_ image: Image) -> some FlexibleAsyncImageSource {
        FlexibleConstantImageSource(image: image)
    }
}

public struct FlexibleConstantImageSource: FlexibleAsyncImageSource, Identifiable {

    public let id: String
    @MainActor public var cachedImage: Image? { image }
    private let image: Image

    public init(image: Image, id: String) {
        self.id = id
        self.image = image
    }

    public init(image: Image) {
        self.init(image: image, id: UUID().uuidString)
    }

    public func loadImage() async throws -> Image {
        image
    }

}
