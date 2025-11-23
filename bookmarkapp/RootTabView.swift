//
//  RootTabView.swift
//  bookmarkapp
//
//  Created by AI on 17/11/2025.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    private enum Tab: Hashable {
        case home
        case add
        case library
    }
    
    @State private var selectedTab: Tab = .home
    @State private var lastNonAddTab: Tab = .home
    
    // Shared scan / OCR state for the Add action.
    @State private var showSourcePanel: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Home
                ContentView()
                    .tabItem {
                        Image("tabbar-home")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                // Add / Scan – behaves like an action, not its own page.
                Color.clear
                    .tabItem {
                        Image("tabbar-add")
                        Text("Add")
                    }
                    .tag(Tab.add)
                
                // Library
                NavigationStack {
                    MyBooksView()
                }
                .tabItem {
                    Image("tabbar-library")
                    Text("My library")
                }
                .tag(Tab.library)
                
                // NOTE: Settings and Search views are kept in the codebase but
                // intentionally hidden from the tab bar for now.
                //
                // NavigationStack { SettingsMenuView() }
                //     .tabItem {
                //         Image(systemName: "gearshape.fill")
                //         Text("Settings")
                //     }
                //
                // NavigationStack { SearchPlaceholderView() }
                //     .tabItem {
                //         Image(systemName: "magnifyingglass")
                //         Text("Search")
                //     }
            }
            
            if showSourcePanel {
                SourceSelectionPanel(
                    onTakePhoto: {
                        showSourcePanel = false
                        showCamera = true
                    },
                    onImportFromPhotos: {
                        showSourcePanel = false
                        showPhotoPicker = true
                    },
                    onCancel: {
                        showSourcePanel = false
                    }
                )
                .padding(.bottom, 72) // slightly above the tab bar / Add icon
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .onChange(of: selectedTab) { newValue in
            // Make the middle tab act like a quick action instead of a real page.
            if newValue == .add {
                selectedTab = lastNonAddTab
                showSourcePanel = true
            } else {
                lastNonAddTab = newValue
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { img in
                // Drive the OCR review directly from the captured image.
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { img in
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .fullScreenCover(item: $ocrImageItem) { item in
            NavigationStack {
                OCRReviewView(
                    image: item.image,
                    onRescan: {
                        // Dismiss and reopen the source selector so the user
                        // can quickly rescan from the Add action.
                        ocrImageItem = nil
                        showSourcePanel = true
                    }
                )
            }
        }
    }
}

// MARK: - Source selection panel anchored near the Add icon

private struct SourceSelectionPanel: View {
    var onTakePhoto: () -> Void
    var onImportFromPhotos: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Select Source")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)
            
            Button {
                onTakePhoto()
            } label: {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Take Photo")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                onImportFromPhotos()
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text("Import from Photos")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(role: .cancel) {
                onCancel()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThickMaterial)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 32)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: UUID())
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


