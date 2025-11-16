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
        
        // System serif font and comfortable reading size similar to Instapaper.
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        if let serifDescriptor = baseFont.fontDescriptor.withDesign(.serif) {
            textView.font = UIFont(descriptor: serifDescriptor, size: 18)
        } else {
            textView.font = UIFont.systemFont(ofSize: 18)
        }
        
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 18, bottom: 32, right: 18)
        
        // Use a yellow highlight color instead of the default blue selection tint.
        textView.tintColor = .systemYellow
        
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


