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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        #if DEBUG
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        #endif
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RootTabView()
            } else {
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .modelContainer(for: [Book.self, Quote.self])
    }

    private func configureTabBarAppearance() {
        #if canImport(UIKit)
        UITabBar.appearance().unselectedItemTintColor = UIColor(
            red: 0.506, green: 0.533, blue: 0.596, alpha: 1.0
        )
        #endif
    }
}
