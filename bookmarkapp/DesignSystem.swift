//
//  DesignSystem.swift
//  bookmarkapp
//
//  Centralised colors and fonts used across the app.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The five cover-color options available when manually creating a book.
enum BookCoverColor: String, CaseIterable {
    case blue, red, yellow, purple, green

    var assetName: String {
        "book-thumbnail-icon-\(rawValue)"
    }

    var swatchColor: Color {
        switch self {
        case .blue:   return Color(red: 0.25, green: 0.56, blue: 0.97)
        case .red:    return Color(red: 0.85, green: 0.35, blue: 0.32)
        case .yellow: return Color(red: 0.95, green: 0.78, blue: 0.30)
        case .purple: return Color(red: 0.62, green: 0.51, blue: 0.85)
        case .green:  return Color(red: 0.42, green: 0.72, blue: 0.42)
        }
    }

    var letterColor: Color {
        switch self {
        case .blue:   return Color(red: 0.149, green: 0.400, blue: 0.561) // #26668F
        case .red:    return Color(red: 0.620, green: 0.376, blue: 0.333) // #9E6055
        case .green:  return Color(red: 0.471, green: 0.600, blue: 0.325) // #789953
        case .purple: return Color(red: 0.325, green: 0.361, blue: 0.600) // #535C99
        case .yellow: return Color(red: 0.600, green: 0.502, blue: 0.325) // #998053
        }
    }

    init(rawColorString: String) {
        self = BookCoverColor(rawValue: rawColorString) ?? .blue
    }
}

/// Shared app colors derived from the Figma design.
enum AppColor {
    /// Background/Normal [25] – #F6F8FA
    static let background = Color(red: 0.965, green: 0.973, blue: 0.980)
    
    /// Text/Muted [600] – #36394A
    static let textPrimary = Color(red: 0.212, green: 0.224, blue: 0.290)
    
    /// Text/Normal [500] – #666D80
    static let textSecondary = Color(red: 0.400, green: 0.427, blue: 0.502)
    
    /// Card border – #ECEFF3
    static let cardBorder = Color(red: 0.925, green: 0.937, blue: 0.953)
    
    /// Quote badge background – #DBC1C1
    static let quoteBadge = Color(red: 0.859, green: 0.757, blue: 0.757)

    /// Book thumbnail monogram – #26668F
    static let bookThumbnailLetter = Color(red: 0.149, green: 0.400, blue: 0.561)
    
    /// Text/Loud [900] – #0D0D12 (used for quote card book titles)
    static let textLoud = Color(red: 0.051, green: 0.051, blue: 0.071)
    
    /// Text/Subdued [400] – #818898 (used for quote card timestamps)
    static let textSubdued = Color(red: 0.506, green: 0.533, blue: 0.596)
    
    /// Stronger card border – #DFE1E7 (used for quote cards)
    static let cardBorderStrong = Color(red: 0.875, green: 0.882, blue: 0.906)
    
    /// Dark button fill – #1B1D20 (used for CTA buttons)
    static let buttonDark = Color(red: 0.106, green: 0.114, blue: 0.125)
    
    /// Gold accent – #EBC658 at 80% opacity (used for floating Add button)
    static let addButtonGold = Color(red: 235.0 / 255.0, green: 198.0 / 255.0, blue: 88.0 / 255.0)
    
    /// Glass icon foreground – #404040
    static let glassIconForeground = Color(red: 0.251, green: 0.251, blue: 0.251)
    
    /// Text/Normal [500] – #666D80 (used for book author on cards)
    static let textNormal = Color(red: 0.400, green: 0.427, blue: 0.502)
    
    /// Text/Muted [600] – #36394A (used for quote body text)
    static let textMuted = Color(red: 0.212, green: 0.224, blue: 0.290)
}

/// Shared gradients derived from the Figma design.
enum AppGradient {
    /// Book thumbnail background – soft pink diagonal gradient
    /// from #FFE0E0 to #EC9F9F, matching the home "My books" cards.
    static let bookThumbnailPink = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.88, blue: 0.88),                    // #FFE0E0
            Color(red: 236.0 / 255.0, green: 159.0 / 255.0, blue: 159.0 / 255.0) // #EC9F9F
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Book thumbnail background – soft gold diagonal gradient
    /// from #FFF5E3 to #EBD09D, used for alternate book thumbnails.
    static let bookThumbnailGold = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.96, blue: 0.89),                    // #FFF5E3
            Color(red: 235.0 / 255.0, green: 208.0 / 255.0, blue: 157.0 / 255.0) // #EBD09D
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Profile icon background – soft violet circle used for the user initial
    /// on the home screen. Derived from the Figma ellipse styling.
    static let profileIcon = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.75, green: 0.67, blue: 0.99),
            Color(red: 0.63, green: 0.50, blue: 0.96)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Shared font helpers for Apple New York and SF Pro.
enum AppFont {
    /// Screen title – "Booklights"
    static let screenTitle = Font.system(size: 24, weight: .medium, design: .serif)
    
    /// Book thumbnail initial – New York Regular 28.
    static let bookInitial = Font.system(size: 28, weight: .regular, design: .serif)
    
    /// Book title on card.
    static let bookTitle = Font.system(size: 16, weight: .medium, design: .serif)
    
    /// Book author on card (SF Pro Text Regular).
    static let bookAuthor = Font.system(size: 14, weight: .regular, design: .default)
    
    /// Quote count badge number.
    static let quoteBadge = Font.system(size: 12, weight: .semibold, design: .serif)
    
    /// Section titles on home such as "My books" / "Recent highlights"
    /// – SF Pro Text Medium 16.
    static let sectionTitle = Font.system(size: 16, weight: .medium, design: .default)
    
    /// Body text for quote content on the home "Recent highlights" cards
    /// – New York Regular 16 (legacy style, kept for compatibility).
    static let quoteBody = Font.system(size: 16, weight: .regular, design: .serif)
    
    /// Quote card book title – New York Regular 16, line height 26.
    static let quoteCardTitle = Font.system(size: 16, weight: .regular, design: .serif)
    
    /// Quote card timestamp – Inter Regular 14, line height 26.
    static let quoteCardTimestamp = Font.system(size: 14, weight: .regular, design: .default)
    
    /// Quote card body – Inter Regular 16, line height 28.
    static let quoteCardBody = Font.system(size: 16, weight: .regular, design: .default)

    /// Profile icon initial – New York Semibold 20, used for the single-letter
    /// monogram inside the circular profile icon on the home screen.
    static let profileInitial = Font.system(size: 20, weight: .semibold, design: .serif)
    
    /// Large screen title – 32pt Semibold (e.g. "Home")
    static let largeTitle = Font.system(size: 32, weight: .semibold, design: .default)
    
    /// Empty state heading – 22pt Semibold
    static let emptyStateTitle = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// Empty state body – 16pt Regular
    static let emptyStateBody = Font.system(size: 16, weight: .regular, design: .default)
    
    /// CTA button label – 16pt Medium
    static let buttonLabel = Font.system(size: 16, weight: .medium, design: .default)
    
    /// Home section title – 22pt SemiBold (matches Figma "Overused Grotesk SemiBold")
    static let homeSectionTitle = Font.system(size: 22, weight: .semibold, design: .default)

    /// Toast message – 14pt Medium
    static let toastMessage = Font.system(size: 14, weight: .medium, design: .default)
}

// MARK: - App Notifications

extension Notification.Name {
    static let highlightAdded = Notification.Name("highlightAdded")
    static let bookCreated = Notification.Name("bookCreated")
}

// MARK: - Success Toast

struct SuccessToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(red: 0.30, green: 0.69, blue: 0.31))

            Text(message)
                .font(AppFont.toastMessage)
                .foregroundStyle(Color(red: 0.18, green: 0.19, blue: 0.22))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Toast View Modifier

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if isPresented {
                SuccessToastView(message: message)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isPresented)
    }
}

extension View {
    func successToast(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}
