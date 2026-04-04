import SwiftUI
import SwiftData
import UIKit

struct OCRReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let image: UIImage
    var onRescan: (() -> Void)? = nil
    var preselectedBook: Book? = nil

    @State private var fullText: String = ""
    @State private var selectedText: String = ""
    @State private var hasSelection: Bool = false
    @State private var clearSelectionID: Int = 0
    @State private var showingBookPicker: Bool = false
    @State private var isLoading: Bool = true
    @State private var ocrErrorMessage: String? = nil
    /// Snapshot of the user's selected text at the time they tap "Save highlight".
    /// This avoids losing the selection when we clear the UI highlight before
    /// the user picks a book.
    @State private var pendingSelectedText: String = ""

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Running OCR…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task { await runOCR() }
            } else if let message = ocrErrorMessage {
                // Error state: show a friendly message and allow user to rescan.
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
                VStack(spacing: 0) {
                    InstructionsBanner()
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    SelectableTextView(
                        text: fullText,
                        selectedText: $selectedText,
                        hasSelection: $hasSelection,
                        clearSelectionID: $clearSelectionID
                    )
                }

                if hasSelection,
                   !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack {
                        Spacer()
                        Button {
                            let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            pendingSelectedText = trimmed
                            clearSelectionID &+= 1
                            hasSelection = false
                            showingBookPicker = true
                        } label: {
                            Text("Save highlight")
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
        .background(Color.white)
        .sheet(isPresented: $showingBookPicker) {
            BookPickerView(preselectedBook: preselectedBook) { book in
                save(to: book)
                showingBookPicker = false
                dismiss()
            }
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
                        .foregroundStyle(AppColor.glassIconForeground)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let onRescan {
                    Button {
                        onRescan()
                    } label: {
                        Image(systemName: "camera.viewfinder")
                    }
                    .accessibilityLabel("Retake photo")
                }
            }
        }
    }

    private func runOCR() async {
        do {
            let lines = try await OCRService.recognizeText(in: image)
            await MainActor.run {
                self.fullText = processLinesIntoParagraphs(lines)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.ocrErrorMessage = "Please try again."
                self.isLoading = false
            }
        }
    }

    /// Converts OCR lines into paragraph-style text by grouping lines based
    /// on their vertical spacing in the image. Larger vertical gaps are
    /// treated as paragraph breaks.
    private func processLinesIntoParagraphs(_ lines: [OCRService.OCRLine]) -> String {
        guard !lines.isEmpty else { return "" }

        // Sort lines top-to-bottom. Vision's coordinate system has origin at
        // the bottom-left, so a larger minY means visually higher on the page.
        let sorted = lines.sorted { $0.minY > $1.minY }

        // Compute gaps between consecutive lines.
        var gaps: [CGFloat] = []
        if sorted.count > 1 {
            for index in 1..<sorted.count {
                let gap = sorted[index - 1].minY - sorted[index].minY
                gaps.append(max(gap, 0))
            }
        }

        // Derive a heuristic threshold for what counts as a "large" gap.
        // If we don't have enough gaps, fall back to a simple join.
        guard let threshold = makeParagraphGapThreshold(from: gaps) else {
            let allText = sorted
                .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            return allText
        }

        var paragraphs: [[String]] = []
        var currentParagraph: [String] = []

        func appendCurrentParagraphIfNeeded() {
            if !currentParagraph.isEmpty {
                paragraphs.append(currentParagraph)
                currentParagraph.removeAll()
            }
        }

        currentParagraph.append(
            sorted[0].text.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        for index in 1..<sorted.count {
            let line = sorted[index]
            let trimmed = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let previousLine = sorted[index - 1]
            let gap = max(previousLine.minY - line.minY, 0)

            if gap > threshold {
                // Large vertical gap → paragraph break.
                appendCurrentParagraphIfNeeded()
                currentParagraph.append(trimmed)
            } else {
                currentParagraph.append(trimmed)
            }
        }

        appendCurrentParagraphIfNeeded()

        // Join lines within paragraphs with a space, and paragraphs with
        // a blank line, preserving the current UI behavior.
        return paragraphs
            .map { $0.joined(separator: " ") }
            .joined(separator: "\n\n")
    }

    /// Computes a heuristic paragraph gap threshold from the collection of
    /// vertical gaps between lines. Uses the median gap scaled by a factor
    /// to distinguish "normal line spacing" from "paragraph spacing".
    private func makeParagraphGapThreshold(from gaps: [CGFloat]) -> CGFloat? {
        guard !gaps.isEmpty else { return nil }

        let sortedGaps = gaps.sorted()
        let median: CGFloat

        if sortedGaps.count % 2 == 0 {
            let midHigh = sortedGaps.count / 2
            let midLow = midHigh - 1
            median = (sortedGaps[midLow] + sortedGaps[midHigh]) / 2
        } else {
            median = sortedGaps[sortedGaps.count / 2]
        }

        // If median is extremely small, fall back to nil to avoid
        // over-splitting paragraphs on noisy spacing.
        guard median > 0 else { return nil }

        // A multiplier between 1.4–1.8 tends to work reasonably well for
        // book-like layouts; this keeps "normal" line spacing grouped
        // while treating clearly larger gaps as paragraph breaks.
        return median * 1.6
    }

    private func save(to book: Book) {
        let baseText = pendingSelectedText.isEmpty ? selectedText : pendingSelectedText
        let trimmed = baseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let quote = Quote(
            text: trimmed,
            page: nil,
            note: nil,
            book: book
        )
        modelContext.insert(quote)
        book.quotes.append(quote)
        try? modelContext.save()

        selectedText = ""
        pendingSelectedText = ""
        hasSelection = false
        clearSelectionID &+= 1
    }
}

// MARK: - Instructions Banner

private struct InstructionsBanner: View {
    private let highlightBlue = Color(red: 0, green: 0.533, blue: 1)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image("hold-icon")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 28, height: 28)

                Text("Hold and drag to select a quote to save")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }

            Text("You don\u{2019}t rise to the level of your goals, you fall to the level of your systems.")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(.black)
                .lineSpacing(11)
                .overlay(
                    highlightBlue
                        .opacity(0.25)
                        .blendMode(.multiply)
                        .clipShape(RoundedRectangle(cornerRadius: 1))
                        .padding(.horizontal, -2)
                        .padding(.vertical, -3)
                )
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(highlightBlue)
                        .frame(width: 2)
                        .padding(.top, -4)
                        .padding(.bottom, 0)
                }
                .overlay(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(highlightBlue)
                        .frame(width: 2)
                        .padding(.top, 0)
                        .padding(.bottom, -4)
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColor.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
        )
    }
}
