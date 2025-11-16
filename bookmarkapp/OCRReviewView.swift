import SwiftUI
import SwiftData
import UIKit

struct OCRReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let image: UIImage
    var onRescan: (() -> Void)? = nil

    @State private var fullText: String = ""
    @State private var selectedText: String = ""
    @State private var hasSelection: Bool = false
    @State private var clearSelectionID: Int = 0
    @State private var search: String = ""
    @State private var showingBookPicker: Bool = false
    @State private var isLoading: Bool = true
    @State private var ocrErrorMessage: String? = nil

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
                // Full text in a selectable, scrollable view on a clean white background.
                VStack(spacing: 0) {
                    SelectableTextView(
                        text: fullText,
                        selectedText: $selectedText,
                        hasSelection: $hasSelection,
                        clearSelectionID: $clearSelectionID
                    )
                }

                // Floating primary button when there is a selection
                if hasSelection,
                   !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack {
                        Spacer()
                        Button {
                            // Clear the visual selection before moving to the next step.
                            clearSelectionID &+= 1
                            hasSelection = false
                            showingBookPicker = true
                        } label: {
                            Text("Save highlight")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: hasSelection)
                }
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showingBookPicker) {
            BookPickerView { book in
                save(to: book)
            }
        }
        .navigationTitle("Select highlight")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
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

        // Clear selection so the user can select a new portion.
        selectedText = ""
        hasSelection = false
        clearSelectionID &+= 1
    }
}
