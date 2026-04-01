import Foundation

private struct SearchResponse: Decodable {
    let docs: [SearchDoc]
}

private struct SearchDoc: Decodable {
    let key: String
    let title: String
    let author_name: [String]?
    let cover_i: Int?
}

let url = URL(string: "https://openlibrary.org/search.json?q=swift+programming&limit=12&fields=key,title,author_name,cover_i")!
let group = DispatchGroup()
group.enter()
URLSession.shared.dataTask(with: url) { data, _, _ in
    defer { group.leave() }
    guard let data = data else { return }
    do {
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        print("Success! \(response.docs.count)")
    } catch {
        print("Error: \(error)")
    }
}.resume()
group.wait()
