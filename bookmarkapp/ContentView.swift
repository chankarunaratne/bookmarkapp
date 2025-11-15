//
//  ContentView.swift
//  bookmarkapp
//
//  Created by Chandima Karunaratne on 9/11/2025.
//

import SwiftUI
import UIKit
import SwiftData

struct ContentView: View {
    @State private var showSourceDialog: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var ocrImageItem: OCRImageItem?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        BooksListView()
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 120) // space for floating button
                }
                .background(Color(.systemGroupedBackground))
                
                scanBookButton
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { img in
                // Drive the OCR sheet directly from the captured image.
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { img in
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .sheet(item: $ocrImageItem, onDismiss: { ocrImageItem = nil }) { item in
            NavigationStack {
                OCRReviewView(
                    image: item.image,
                    onRescan: {
                        // Dismiss current OCR sheet and reopen source selection.
                        ocrImageItem = nil
                        showSourceDialog = true
                    }
                )
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "bookmark.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bookmarks")
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                        Text("Your collection of quotes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Menu")
            }
        }
    }
    
    private var scanBookButton: some View {
        Button {
            showSourceDialog = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                Text("Scan Book")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
        }
        .foregroundStyle(.white)
        .background(
            Capsule()
                .fill(Color.accentColor)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        .confirmationDialog("Select Source", isPresented: $showSourceDialog) {
            Button("Take Photo") { showCamera = true }
            Button("Import from Photos") { showPhotoPicker = true }
            Button("Cancel", role: .cancel) {}
        }
    }
}

/// Identifiable wrapper so the OCR sheet is only presented when
/// there is a concrete image, avoiding empty sheet content.
private struct OCRImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}
