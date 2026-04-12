import SwiftUI

class ImageCache {
    static let shared = ImageCache()

    private let fm = FileManager.default
    private let cacheDirectory: URL
    private let legacyCacheDirectory: URL
    private let ioQueue = DispatchQueue(label: "bookmarkapp.imagecache")

    /// Total on-disk footprint before LRU eviction removes oldest files (by modification date).
    private let maxCacheBytes: Int64 = 100 * 1024 * 1024

    private init() {
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("BookCovers", isDirectory: true)
        let documents = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        legacyCacheDirectory = documents.appendingPathComponent("BookCovers", isDirectory: true)

        ioQueue.sync {
            try? fm.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            migrateLegacyCacheIfNeeded()
        }
    }

    private func migrateLegacyCacheIfNeeded() {
        guard fm.fileExists(atPath: legacyCacheDirectory.path) else { return }
        guard let names = try? fm.contentsOfDirectory(atPath: legacyCacheDirectory.path) else { return }
        for name in names {
            let source = legacyCacheDirectory.appendingPathComponent(name)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: source.path, isDirectory: &isDir), !isDir.boolValue else { continue }
            let destination = cacheDirectory.appendingPathComponent(name)
            if fm.fileExists(atPath: destination.path) {
                try? fm.removeItem(at: source)
            } else {
                try? fm.moveItem(at: source, to: destination)
            }
        }
        try? fm.removeItem(at: legacyCacheDirectory)
    }

    func url(for cacheKey: String) -> URL {
        let filename = cacheKey.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(filename)
    }

    func getImage(for cacheKey: String) -> UIImage? {
        ioQueue.sync {
            let fileURL = url(for: cacheKey)
            guard let data = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: data) else { return nil }
            try? fm.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            return image
        }
    }

    func saveImage(_ image: UIImage, for cacheKey: String) {
        ioQueue.sync {
            let fileURL = url(for: cacheKey)
            guard let data = image.jpegData(compressionQuality: 0.9) else { return }
            try? data.write(to: fileURL, options: .atomic)
            trimCacheIfNeeded()
        }
    }

    private func trimCacheIfNeeded() {
        guard let urls = try? fm.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        var entries: [(url: URL, size: Int64, date: Date)] = []
        var total: Int64 = 0
        for url in urls {
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let size = values.fileSize else { continue }
            let date = values.contentModificationDate ?? .distantPast
            let size64 = Int64(size)
            entries.append((url, size64, date))
            total += size64
        }
        guard total > maxCacheBytes else { return }

        let sorted = entries.sorted { $0.date < $1.date }
        for entry in sorted {
            guard total > maxCacheBytes else { break }
            try? fm.removeItem(at: entry.url)
            total -= entry.size
        }
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
