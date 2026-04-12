//
//  SettingsMenuView.swift
//  bookmarkapp
//

import SwiftUI
import SafariServices

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct SettingsMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var safariURL: URL?

    private let linkItems: [(title: String, id: String)] = [
        ("Terms and Conditions", "terms"),
        ("Privacy Policy", "privacy"),
        ("Contact Us", "contact")
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    feedbackBanner
                    linksList

                    Text("Designed and developed by\nChandima Bandara")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(.systemGray2))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }

    // MARK: - Feedback Banner

    private var feedbackBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Share your feedback")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.textLoud)

                Text("Help us improve by sharing your thoughts.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Button {
                safariURL = URL(string: "https://cg94.typeform.com/to/P0WT4Lks")
            } label: {
                Text("Share")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(AppColor.buttonDark)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Links List

    private var linksList: some View {
        VStack(spacing: 0) {
            ForEach(Array(linkItems.enumerated()), id: \.element.id) { index, item in
                Button {
                    handleLinkTap(item.id)
                } label: {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(AppColor.textLoud)

                        Spacer()

                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColor.textSubdued)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)

                if index < linkItems.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func handleLinkTap(_ id: String) {
        switch id {
        case "terms":
            safariURL = URL(string: "https://getrememberly.app/terms")
        case "privacy":
            safariURL = URL(string: "https://getrememberly.app/privacy-policy")
        case "contact":
            openSupportEmail()
        default:
            break
        }
    }

    private func openSupportEmail() {
        if let url = URL(string: "mailto:contact@getrememberly.app") {
            openURL(url)
        }
    }
}

#Preview {
    SettingsMenuView()
}
