//
//  OpenLibraryService.swift
//  bookmarkapp
//
//  Lightweight client for the Open Library Search API.
//  No API key or account required – completely free.
//

import Foundation
import Combine

// MARK: - Search Result Model

struct OpenLibrarySearchResult: Identifiable, Equatable {
    let id: String          // Open Library key, e.g. "/works/OL12345W"
    let title: String
    let author: String?
    let coverURL: URL?      // Medium-sized cover image

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API Response DTOs

private struct SearchResponse: Decodable {
    let docs: [SearchDoc]
}

private struct SearchDoc: Decodable {
    let key: String             // e.g. "/works/OL2163649W"
    let title: String
    let author_name: [String]?
    let cover_i: Int?           // Cover ID for covers.openlibrary.org
}

// MARK: - Service

@MainActor
final class OpenLibraryService: ObservableObject {
    @Published var results: [OpenLibrarySearchResult] = []
    @Published var isSearching: Bool = false
    @Published var searchText: String = ""

    private var searchCancellable: AnyCancellable?

    init() {
        // Debounce search input – wait 400ms after the user stops typing
        // before firing a network request.
        searchCancellable = $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count < 2 {
                    self.results = []
                    return
                }
                Task { await self.search(query: trimmed) }
            }
    }

    // MARK: - Network

    private func search(query: String) async {
        isSearching = true
        defer { isSearching = false }

        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?q=\(encoded)&limit=12&fields=key,title,author_name,cover_i")
        else {
            results = []
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)

            results = response.docs.map { doc in
                let coverURL: URL? = {
                    guard let coverId = doc.cover_i else { return nil }
                    return URL(string: "https://covers.openlibrary.org/b/id/\(coverId)-M.jpg")
                }()

                return OpenLibrarySearchResult(
                    id: doc.key,
                    title: doc.title,
                    author: doc.author_name?.first,
                    coverURL: coverURL
                )
            }
        } catch {
            // Silently handle – user can still add manually
            results = []
        }
    }
}
