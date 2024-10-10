import Foundation
import Kingfisher

public struct FlexibleKingfisherImageSourceConfig: Sendable {

    /// Disk cache expiration strategy.
    /// .default  is `.days(7)` according to  Kingfisher `DiskStorage.Config`
    public enum DiskCacheExpiration: Sendable {
        case `default`
        case never
    }

    public let diskExpiration: DiskCacheExpiration

    public init(diskExpiration: DiskCacheExpiration = .default) {
        self.diskExpiration = diskExpiration
    }

    /// Singleton function to force clean internal "never-expiring" disk cache
    public static func clearNeverExpiringDiskCache() {
        do {
            let diskStorage = try DiskStorage.Backend<Data>(config: neverExpiringDiskConfig)
            try diskStorage.removeAll()
        } catch {
            assertionFailure("Failed to clear never expiring disk cache with error: \(error.localizedDescription)")
        }
    }

    // MARK: - Internal

    func makeCache() -> ImageCache {
        guard diskExpiration != .default else { return ImageCache.default }
        do {
            return ImageCache(
                memoryStorage: MemoryStorage.Backend<KFCrossPlatformImage>(config: memoryConfig),
                diskStorage: try DiskStorage.Backend<Data>(config: diskConfig)
            )
        } catch {
            assertionFailure("Failed to create disk cache with error: \(error.localizedDescription)")
            return ImageCache.default
        }
    }

    // MARK: - Private properties

    private var memoryConfig: MemoryStorage.Config {
        ImageCache.default.memoryStorage.config
    }

    private var diskConfig: DiskStorage.Config {
        switch diskExpiration {
        case .default: Self.defaultDiskConfig
        case .never: Self.neverExpiringDiskConfig
        }
    }

    private static var defaultDiskConfig: DiskStorage.Config {
        ImageCache.default.diskStorage.config
    }

    private static var neverExpiringDiskConfig: DiskStorage.Config {
        var diskConfig = DiskStorage.Config(name: "flexible.never-expiring", sizeLimit: 0, directory: nil)
        diskConfig.expiration = .never
        return diskConfig
    }
}
