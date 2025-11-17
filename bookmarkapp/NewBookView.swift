//
//  NewBookView.swift
//  bookmarkapp
//
//  Created by AI on 17/11/2025.
//

import SwiftUI
import SwiftData

struct NewBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    
    private var isCreateDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Book Name")) {
                    TextField("Enter book name", text: $title)
                        .textInputAutocapitalization(.words)
                }
            }
        }
        .navigationTitle("New Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    createBook()
                }
                .disabled(isCreateDisabled)
            }
        }
    }
    
    private func createBook() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let book = Book(title: trimmedTitle)
        modelContext.insert(book)
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        NewBookView()
    }
    .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}


