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
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 100, right: 20)
        textView.tintColor = .systemBlue
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            let baseFont = UIFont.preferredFont(forTextStyle: .body)
            let font: UIFont
            if let serifDescriptor = baseFont.fontDescriptor.withDesign(.serif) {
                font = UIFont(descriptor: serifDescriptor, size: 18)
            } else {
                font = UIFont.systemFont(ofSize: 18)
            }

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 11
            paragraphStyle.paragraphSpacing = 16

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(red: 0.212, green: 0.224, blue: 0.290, alpha: 1),
                .paragraphStyle: paragraphStyle
            ]

            uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
        }

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


