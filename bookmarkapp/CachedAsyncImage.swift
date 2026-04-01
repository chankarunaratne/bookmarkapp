import SwiftUI
import Combine

class ImageCache {
    static let shared = ImageCache()
    private let cacheDirectory: URL
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("BookCovers")
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func url(for cacheKey: String) -> URL {
        // Base64 encode the string to use as filenames safely
        let filename = cacheKey.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func getImage(for cacheKey: String) -> UIImage? {
        let fileURL = url(for: cacheKey)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    func saveImage(_ image: UIImage, for cacheKey: String) {
        let fileURL = url(for: cacheKey)
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        try? data.write(to: fileURL)
    }
}

enum CachedAsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let fetchWhenUrlChanges: Bool
    private let content: (CachedAsyncImagePhase) -> Content
    
    @State private var phase: CachedAsyncImagePhase = .empty
    
    init(url: URL?, fetchWhenUrlChanges: Bool = true, @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content) {
        self.url = url
        self.fetchWhenUrlChanges = fetchWhenUrlChanges
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .task(id: fetchWhenUrlChanges ? url : nil) {
                await load()
            }
    }
    
    @MainActor
    private func load() async {
        guard let url = url else {
            phase = .empty
            return
        }
        
        let cacheKey = url.absoluteString
        if let cachedImage = ImageCache.shared.getImage(for: cacheKey) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                ImageCache.shared.saveImage(uiImage, for: cacheKey)
                phase = .success(Image(uiImage: uiImage))
            } else {
                phase = .failure(URLError(.cannotDecodeRawData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}
