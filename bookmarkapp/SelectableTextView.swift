import SwiftUI
import UIKit

/// A UIKit-backed text view that supports native text selection and
/// reports the currently selected text back to SwiftUI.
struct SelectableTextView: UIViewRepresentable {
    let text: String
    @Binding var selectedText: String
    @Binding var hasSelection: Bool
    @Binding var clearSelectionID: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        // Clear selection when requested by SwiftUI.
        if context.coordinator.lastClearSelectionID != clearSelectionID {
            uiView.selectedRange = NSRange(location: 0, length: 0)
            context.coordinator.lastClearSelectionID = clearSelectionID
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: SelectableTextView
        var lastClearSelectionID: Int = 0

        init(_ parent: SelectableTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            let selectedRange = textView.selectedRange

            guard selectedRange.length > 0,
                  let text = textView.text,
                  let range = Range(selectedRange, in: text) else {
                parent.selectedText = ""
                parent.hasSelection = false
                return
            }

            let selected = String(text[range])
            parent.selectedText = selected
            parent.hasSelection = !selected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}


