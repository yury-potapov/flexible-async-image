import SwiftUI

public enum FlexibleAsyncPhase {
    case empty
    case success(Image)
    case failure(Error?)
}

public protocol FlexibleAsyncImageSource: Sendable {
    @MainActor var cachedImage: Image? { get }
    func loadImage() async throws -> Image
}

/// Analogue for AsyncImage with custom loaders
/// https://developer.apple.com/documentation/swiftui/asyncimage
public struct FlexibleAsyncImage<Content: View>: View {

    public var body: some View {
        content(phase)
            .task {
                guard phase.isEmpty else { return }
                do {
                    let loadedImage = try await source.loadImage()
                    phase = .success(loadedImage)
                } catch {
                    phase = .failure(error)
                }
            }
    }

    @MainActor
    public init(
        source: FlexibleAsyncImageSource,
        @ViewBuilder content: @escaping (FlexibleAsyncPhase) -> Content
    ) {
        self.content = content
        self.source = source

        // Do not trigger any calls of `content(.empty)` when cached value exists
        if let cachedImage = source.cachedImage {
            _phase = State(initialValue: .success(cachedImage))
        } else {
            _phase = State(initialValue: .empty)
        }
    }

    @MainActor
    public init<I: View, P: View>(
        source: FlexibleAsyncImageSource,
        content: @escaping (Image) -> I,
        placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(source: source) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }

    // MARK: - Private properties

    @State private var phase: FlexibleAsyncPhase
    private let source: FlexibleAsyncImageSource
    private let content: (FlexibleAsyncPhase) -> Content
}

private extension FlexibleAsyncPhase {
    var image: Image? {
        guard case .success(let image) = self else { return nil }
        return image
    }

    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

    var isEmpty: Bool {
        switch self {
        case .empty: return true
        default: return false
        }
    }
}
