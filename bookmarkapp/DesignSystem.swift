//
//  DesignSystem.swift
//  bookmarkapp
//
//  Centralised colors and fonts used across the app.
//

import SwiftUI

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
}


