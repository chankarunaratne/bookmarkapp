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
        case library
    }
    
    @State private var selectedTab: Tab = .home
    
    @State private var showSourcePanel: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                ContentView(onSaveHighlight: { showSourcePanel = true })
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                MyBooksView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("My library")
                }
                .tag(Tab.library)
            }
            .tint(AppColor.textPrimary)
            
            // Floating golden Add button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showSourcePanel = true
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.glassIconForeground)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(AppColor.addButtonGold.opacity(0.8))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 25)
            .padding(.bottom, 16)
            .accessibilityLabel("Add highlight")
            
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
                .padding(.bottom, 72)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { img in
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


