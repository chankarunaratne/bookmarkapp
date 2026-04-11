//
//  RootTabView.swift
//  bookmarkapp
//
//  Created by AI on 17/11/2025.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    private enum TabID: Hashable {
        case home
        case library
        case add
    }
    
    @State private var selectedTab: TabID = .home
    
    @State private var showCamera: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    ContentView(
                        onSaveHighlight: { showCamera = true },
                        onTapMyLibrary: { selectedTab = .library }
                    )
                }
                
                Tab("My library", systemImage: "book.pages", value: .library) {
                    MyBooksView()
                }
                
                // Uses the .search role so the system pins it separately on the right
                Tab("Add highlight", systemImage: "plus", value: .add, role: .search) {
                    Color.clear
                }
            }
            .tint(AppColor.textPrimary)
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .add {
                    selectedTab = oldValue
                    showCamera = true
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CustomCameraView { img in
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .fullScreenCover(item: $ocrImageItem) { item in
            NavigationStack {
                OCRReviewView(
                    image: item.image,
                    onRescan: {
                        ocrImageItem = nil
                        showCamera = true
                    }
                )
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}

