import Kingfisher
import FlexibleAsyncImage
import SwiftUI

/// ImageLoader implementation based on Kingfisher
///
/// Provides cancellable async throwing function loadImage().
public struct FlexibleKingfisherImageSource: FlexibleAsyncImageSource, Identifiable {
    public let url: URL

    public var id: String { cacheKey }
    @MainActor public var cachedImage: Image? {
        cache.retrieveImageInMemoryCache(forKey: cacheKey)?.swiftUiImage
    }

    /// Default initializer for `FlexibleKingfisherImageSource`.
    ///
    /// - Parameters:
    ///   - url: `URL` of target image.
    ///   - config: `URLImageSourceConfig` configuration.
    /// - Returns: An instance of `URLImageSource`
    public init(url: URL, config: FlexibleKingfisherImageSourceConfig = FlexibleKingfisherImageSourceConfig()) {
        self.url = url
        self.cacheKey = "url:" + url.absoluteString
        self.cache = config.makeCache()
    }

    /// Helper optional initializer.
    ///
    /// - Parameters:
    ///   - url: Optional `URL` of target image.
    ///   - config: `URLImageSourceConfig`
    /// - Returns: An instance of `URLImageSource` when url is presented  and `nil` otherwise
    public init?(url: URL?, config: FlexibleKingfisherImageSourceConfig = FlexibleKingfisherImageSourceConfig()) {
        guard let url else { return nil }
        self.init(url: url, config: config)
    }

    // TODO: implement workaround for the race in Kingfisher: https://github.com/onevcat/Kingfisher/issues/2231
    public func loadImage() async throws -> Image {
        let resource = KF.ImageResource(downloadURL: url, cacheKey: id)
        let result = try await KingfisherManager.shared.retrieveImage(
            with: resource,
            options: [
                .targetCache(cache)
            ]
        )
        return result.image.swiftUiImage
    }

    // MARK: - Private properties
    private let cacheKey: String
    private let cache: ImageCache
}

private extension CacheType {
    var debugDescription: String {
        switch self {
        case .disk: "disk"
        case .memory: "memory"
        case .none: "network"
        }
    }
}

private extension KFCrossPlatformImage {
    var swiftUiImage: Image {
        Image(uiImage: self)
    }
}
