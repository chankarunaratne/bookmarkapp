//
//  RootTabView.swift
//  bookmarkapp
//
//  Created by AI on 17/11/2025.
//

import SwiftUI
import SwiftData
import Photos

struct RootTabView: View {
    private enum TabID: Hashable {
        case home
        case library
        case add
    }
    
    @State private var selectedTab: TabID = .home
    
    @State private var showSourcePanel: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    ContentView(onSaveHighlight: { showSourcePanel = true })
                }
                
                Tab("My library", systemImage: "books.vertical", value: .library) {
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
                    // Revert to the previous real tab
                    selectedTab = oldValue
                    // Show the source panel
                    showSourcePanel = true
                }
            }
        }
        .sheet(isPresented: $showSourcePanel) {
            AddHighlightSheet(
                onTakePhoto: {
                    showSourcePanel = false
                    showCamera = true
                },
                onImportFromPhotos: {
                    showSourcePanel = false
                    showPhotoPicker = true
                },
                onSelectImage: { img in
                    showSourcePanel = false
                    ocrImageItem = OCRImageItem(image: img)
                }
            )
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
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

struct AddHighlightSheet: View {
    var onTakePhoto: () -> Void
    var onImportFromPhotos: () -> Void
    var onSelectImage: (UIImage) -> Void
    
    @State private var recentImages: [UIImage] = []
    @State private var hasPhotoAccess: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                // Upload Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Upload")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(red: 0.05, green: 0.05, blue: 0.07)) // #0D0D12
                            
                            Text("Capture text from a photo")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(red: 0.21, green: 0.22, blue: 0.29)) // #36394A
                        }
                        
                        Spacer()
                        
                        Button(action: onImportFromPhotos) {
                            Text("All photos")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(red: 0.01, green: 0.52, blue: 1.0)) // #0285FE
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Recent photos scroll or grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if hasPhotoAccess {
                                ForEach(0..<recentImages.count, id: \.self) { index in
                                    Button {
                                        onSelectImage(recentImages[index])
                                    } label: {
                                        Image(uiImage: recentImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                // Pad empty spaces if < 4 photos exist
                                let emptyCount = max(0, 4 - recentImages.count)
                                if emptyCount > 0 {
                                    ForEach(0..<emptyCount, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85)) // placeholder
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            } else {
                                ForEach(0..<4, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                // Take Photo Section
                Button(action: onTakePhoto) {
                    HStack(spacing: 16) {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.primary)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Take photo")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(red: 0.05, green: 0.05, blue: 0.07)) // #0D0D12
                            
                            Text("Use your camera to capture text")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(red: 0.21, green: 0.22, blue: 0.29)) // #36394A
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Add new")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchRecentPhotos()
            }
        }
    }
    
    private func fetchRecentPhotos() {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if currentStatus == .authorized || currentStatus == .limited {
            self.hasPhotoAccess = true
            loadImages()
        } else if currentStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    self.hasPhotoAccess = (status == .authorized || status == .limited)
                    if self.hasPhotoAccess {
                        self.loadImages()
                    }
                }
            }
        }
    }
    
    private func loadImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 4
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Ensure UI updates happen on main thread
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        let lock = NSLock()
        var fetchedImages: [Int: UIImage] = [:]
        let group = DispatchGroup()
        
        for i in 0..<fetchResult.count {
            let asset = fetchResult.object(at: i)
            group.enter()
            manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOptions) { image, info in
                if let image = image {
                    lock.lock()
                    fetchedImages[i] = image
                    lock.unlock()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            var sortedImages: [UIImage] = []
            for i in 0..<fetchResult.count {
                if let image = fetchedImages[i] {
                    sortedImages.append(image)
                }
            }
            self.recentImages = sortedImages
        }
    }
}
