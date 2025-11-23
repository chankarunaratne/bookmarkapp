//
//  bookmarkappApp.swift
//  bookmarkapp
//
//  Created by Chandima Karunaratne on 9/11/2025.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

@main
struct bookmarkappApp: App {
    
    init() {
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Book.self, Quote.self])
    }
    
    private func configureTabBarAppearance() {
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        let textColor = UIColor.darkGray
        let iconColor = UIColor.darkGray
        
        // Stacked (iPhone)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: textColor]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: textColor]
        appearance.stackedLayoutAppearance.normal.iconColor = iconColor
        appearance.stackedLayoutAppearance.selected.iconColor = iconColor
        
        // Inline / compact inline (iPad, landscape, etc.)
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: textColor]
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: textColor]
        appearance.inlineLayoutAppearance.normal.iconColor = iconColor
        appearance.inlineLayoutAppearance.selected.iconColor = iconColor
        
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: textColor]
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: textColor]
        appearance.compactInlineLayoutAppearance.normal.iconColor = iconColor
        appearance.compactInlineLayoutAppearance.selected.iconColor = iconColor
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        #endif
    }
}
