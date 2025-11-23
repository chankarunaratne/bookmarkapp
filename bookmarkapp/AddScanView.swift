//
//  AddScanView.swift
//  bookmarkapp
//
//  Center \"Add\" tab that replaces the old Scan button on the home screen.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct AddScanView: View {
    @State private var showSourceDialog: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    @State private var didAutoShowSourceDialog: Bool = false
    
    var body: some View {
        NavigationStack {
            Color.clear
                .background(AppColor.background.ignoresSafeArea())
                .navigationTitle("Add")
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog("Select Source", isPresented: $showSourceDialog) {
                    Button("Take Photo") { showCamera = true }
                    Button("Import from Photos") { showPhotoPicker = true }
                    Button("Cancel", role: .cancel) {}
                }
                .navigationDestination(item: $ocrImageItem) { item in
                    OCRReviewView(
                        image: item.image,
                        onRescan: {
                            // Pop back to the Add screen and reopen the source selector.
                            ocrImageItem = nil
                            showSourceDialog = true
                        }
                    )
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
        .onAppear {
            // Automatically open the source selector the first time the user
            // visits the Add tab, mimicking the old Scan button behavior.
            if !didAutoShowSourceDialog {
                didAutoShowSourceDialog = true
                showSourceDialog = true
            }
        }
    }
}

#Preview {
    AddScanView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}


