//
//  SplashScreenView.swift
//  bookmarkapp
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Image("appicon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                logoOpacity = 1
                logoScale = 1
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
