import Foundation

private struct SearchResponse: Decodable {
    let docs: [SearchDoc]
}

private struct SearchDoc: Decodable {
    let key: String             // e.g. "/works/OL2163649W"
    let title: String?
    let author_name: [String]?
    let cover_i: Int?           // Cover ID for covers.openlibrary.org
}

let json = """
{"numFound":3778,"start":0,"numFoundExact":true,"num_found":3778,"documentation_url":"https://openlibrary.org/dev/docs/api/search","q":"harry potter","offset":null,"docs":[{"author_name":["J. K. Rowling"],"cover_i":15155833,"key":"/works/OL82563W","title":"Harry Potter and the Philosopher's Stone"},{"author_name":["J. K. Rowling"],"cover_i":15158660,"key":"/works/OL82586W","title":"Harry Potter and the Deathly Hallows"}]}
"""

do {
    let response = try JSONDecoder().decode(SearchResponse.self, from: json.data(using: .utf8)!)
    print("Success! \(response.docs.count)")
} catch {
    print("Error: \(error)")
}
