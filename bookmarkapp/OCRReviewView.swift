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
    @State private var noTextFound: Bool = false
    @State private var pendingSelectedText: String = ""

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Just a moment...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.white)
                    .foregroundStyle(.white)
                    .task { await runOCR() }
            } else if noTextFound {
                noTextFoundContent
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
                selectionContent

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
        .background(noTextFound ? AppColor.background : Color.black)
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
                        .foregroundStyle(noTextFound ? AppColor.textPrimary : .white)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let onRescan {
                    Button {
                        onRescan()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(noTextFound ? AppColor.textPrimary : .white)
                    }
                    .accessibilityLabel("Retake photo")
                }
            }
        }
    }

    private var noTextFoundContent: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(AppColor.cardBorder)
                        .frame(width: 80, height: 80)

                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(AppColor.textSubdued)
                }

                VStack(spacing: 10) {
                    Text("No text found")
                        .font(AppFont.emptyStateTitle)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("We couldn't read any text in the image. Please try again. Make sure you're in a well lit place and focus the page well in the view.")
                        .font(AppFont.emptyStateBody)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Button {
                    if let onRescan {
                        onRescan()
                    } else {
                        dismiss()
                    }
                } label: {
                    Text("Try again")
                        .font(AppFont.buttonLabel)
                        .foregroundStyle(.white)
                        .frame(height: 36)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColor.buttonDark)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var selectionContent: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 16
            let availableWidth = max(geometry.size.width - (horizontalPadding * 2), 0)
            let imageAspectRatio = image.size.width / max(image.size.height, 1)
            let fittedHeight = availableWidth / max(imageAspectRatio, 0.01)
            let maxStageHeight = max(geometry.size.height - 220, 240)
            let stageHeight = min(fittedHeight, maxStageHeight)

            VStack(spacing: 14) {
                Text("Tap and hold to select text")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textSubdued)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                ZStack {
                    Color.black

                    ImageTextSelectionView(
                        image: image,
                        regions: regions,
                        selectedText: $selectedText,
                        hasSelection: $hasSelection
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: stageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.26), radius: 18, x: 0, y: 8)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func runOCR() async {
        do {
            let result = try await OCRService.recognizeText(in: image)
            await MainActor.run {
                self.regions = result
                self.ocrErrorMessage = nil
                self.noTextFound = result.isEmpty
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.noTextFound = false
                self.ocrErrorMessage = "Please try again."
                self.isLoading = false
            }
        }
    }

}
