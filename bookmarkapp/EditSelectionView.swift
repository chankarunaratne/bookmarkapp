import SwiftUI
import SwiftData

struct EditSelectionView: View {
    @Environment(\.modelContext) private var modelContext

    let initialText: String
    var preselectedBook: Book?
    var onComplete: () -> Void

    @State private var editedText: String = ""
    @State private var pageNumber: String = ""
    @State private var notes: String = ""
    @State private var showingBookPicker: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case highlight, page, notes
    }

    private var isSaveDisabled: Bool {
        editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                highlightSection
                additionalDetailsSection
                selectBookButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Edit selection")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if editedText.isEmpty {
                editedText = initialText
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .sheet(isPresented: $showingBookPicker) {
            BookPickerView(preselectedBook: preselectedBook) { book in
                save(to: book)
                showingBookPicker = false
            }
        }
    }

    // MARK: - Highlight Text Section

    private var highlightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Highlight")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, 8)

            TextEditor(text: $editedText)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($focusedField, equals: .highlight)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(minHeight: 160)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColor.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Additional Details Section

    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional details")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, 8)

            editTextField(
                label: "Page number",
                placeholder: "Enter page number",
                text: $pageNumber,
                field: .page,
                keyboardType: .numberPad
            )

            editTextField(
                label: "Notes",
                placeholder: "Add a note about this highlight",
                text: $notes,
                field: .notes
            )
        }
    }

    // MARK: - Styled Text Field

    private func editTextField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, 8)

            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(AppColor.textSubdued)
                }
                TextField("", text: text)
                    .foregroundStyle(AppColor.textPrimary)
                    .keyboardType(keyboardType)
                    .focused($focusedField, equals: field)
            }
            .font(.system(size: 17, weight: .regular))
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.cardBorder)
            )
        }
    }

    // MARK: - Select Book Button

    private var selectBookButton: some View {
        Button {
            focusedField = nil
            showingBookPicker = true
        } label: {
            Text("Select book")
                .font(AppFont.buttonLabel)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Capsule()
                        .fill(isSaveDisabled ? AppColor.textSubdued : AppColor.buttonDark)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isSaveDisabled)
        .padding(.top, 4)
    }

    // MARK: - Save

    private func save(to book: Book) {
        let trimmed = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let trimmedPage = pageNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let quote = Quote(
            text: trimmed,
            page: trimmedPage.isEmpty ? nil : trimmedPage,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            book: book
        )
        modelContext.insert(quote)
        book.quotes.append(quote)
        try? modelContext.save()

        NotificationCenter.default.post(name: .highlightAdded, object: nil)
        onComplete()
    }
}
