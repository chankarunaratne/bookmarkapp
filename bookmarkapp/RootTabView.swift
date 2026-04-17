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
    @State private var showHighlightToast: Bool = false
    @State private var pendingHighlightToast: Bool = false
    @State private var pendingCameraRetake: Bool = false
    
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
        .successToast(isPresented: $showHighlightToast, message: "Highlight added successfully")
        .fullScreenCover(isPresented: $showCamera) {
            CustomCameraView { img in
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .fullScreenCover(item: $ocrImageItem, onDismiss: {
            if pendingCameraRetake {
                pendingCameraRetake = false
                showCamera = true
            }
            if pendingHighlightToast {
                pendingHighlightToast = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation {
                        showHighlightToast = true
                    }
                }
            }
        }) { item in
            NavigationStack {
                OCRReviewView(
                    image: item.image,
                    onRescan: {
                        pendingCameraRetake = true
                        ocrImageItem = nil
                    }
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .highlightAdded)) { _ in
            pendingHighlightToast = true
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}
