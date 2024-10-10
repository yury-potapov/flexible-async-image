import Combine
import SaftImageLoaderAPI
import SwiftUI

extension CoreImageLoadingSource {
    @MainActor
    public static func constant(_ image: UIImage) -> some CoreImageLoadingSource {
        ConstantImageSource(image: image)
    }
}

public struct ConstantImageSource: CoreImageLoadingSource {
    public let id: String
    public var cachedImage: UIImage? { image }

    public init(image: UIImage, id: String = UUID().uuidString) {
        self.id = id
        self.image = image
    }
    
    public init(image: UIImage, id: String?) {
        if let id {
            self.init(image: image, id: id)
        } else {
            self.init(image: image)
        }
    }

    public func loadImage() async throws -> UIImage {
        image
    }

    private let image: UIImage
}
