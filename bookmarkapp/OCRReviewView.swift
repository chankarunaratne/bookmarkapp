import SwiftUI
import SwiftData
import UIKit

struct OCRReviewView: View {
    @Environment(\.dismiss) private var dismiss

    let image: UIImage
    var onRescan: (() -> Void)? = nil
    var preselectedBook: Book? = nil

    @State private var regions: [OCRService.TextRegion] = []
    @State private var selectedText: String = ""
    @State private var hasSelection: Bool = false
    @State private var showEditSelection: Bool = false
    @State private var isLoading: Bool = true
    @State private var ocrErrorMessage: String? = nil
    @State private var pendingSelectedText: String = ""

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Extracting text from the image.\nThis will only take a moment.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { await runOCR() }
            } else if let message = ocrErrorMessage {
                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 12) {
                        Text("There was an error scanning your page.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    Spacer()

                    if let onRescan {
                        Button {
                            onRescan()
                        } label: {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Scan Book")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            } else {
                ImageTextSelectionView(
                    image: image,
                    regions: regions,
                    selectedText: $selectedText,
                    hasSelection: $hasSelection
                )
                .ignoresSafeArea(edges: .bottom)

                if hasSelection,
                   !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack {
                        Spacer()
                        Button {
                            let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            pendingSelectedText = trimmed
                            showEditSelection = true
                        } label: {
                            Text("Next")
                                .font(AppFont.buttonLabel)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    Capsule()
                                        .fill(AppColor.buttonDark)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: hasSelection)
                }
            }
        }
        .background(Color.black)
        .navigationDestination(isPresented: $showEditSelection) {
            EditSelectionView(
                initialText: pendingSelectedText,
                preselectedBook: preselectedBook,
                onComplete: { dismiss() }
            )
        }
        .navigationTitle("Select highlight")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let onRescan {
                    Button {
                        onRescan()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Retake photo")
                }
            }
        }
    }

    private func runOCR() async {
        do {
            let result = try await OCRService.recognizeText(in: image)
            await MainActor.run {
                self.regions = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.ocrErrorMessage = "Please try again."
                self.isLoading = false
            }
        }
    }

}
