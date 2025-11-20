//
//  RootTabView.swift
//  bookmarkapp
//
//  Created by AI on 17/11/2025.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            ContentView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                MyBooksView()
            }
            .tabItem {
                Image(systemName: "book.closed.fill")
                Text("My library")
            }

            NavigationStack {
                SettingsMenuView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }

            NavigationStack {
                SearchPlaceholderView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
        }
    }
}

// MARK: - Placeholder Search

struct SearchPlaceholderView: View {
    var body: some View {
        Text("Search will be available in a future update.")
            .foregroundStyle(.secondary)
            .padding()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}


