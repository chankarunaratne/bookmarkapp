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
    @State private var showSplash = true
    
    init() {
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    showSplash = false
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
