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
}

/// Shared font helpers for Apple New York and SF Pro.
enum AppFont {
    /// Screen title – "Booklights"
    static let screenTitle = Font.system(size: 24, weight: .medium, design: .serif)
    
    /// Book thumbnail initial.
    static let bookInitial = Font.system(size: 36, weight: .regular, design: .serif)
    
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
    /// – New York Regular 16.
    static let quoteBody = Font.system(size: 16, weight: .regular, design: .serif)
}


