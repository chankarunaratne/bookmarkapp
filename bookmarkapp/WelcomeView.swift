//
//  WelcomeView.swift
//  bookmarkapp
//
//  First-time onboarding screen shown on fresh installs.
//

import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Logo
            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

            Spacer()
                .frame(height: 28)

            // Heading
            Text("Never lose a great\nhighlight again")
                .font(.custom("Newsreader-Bold", size: 28))
                .foregroundStyle(AppColor.textLoud)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

            Spacer()
                .frame(height: 8)

            // Subheading
            Text("Save highlights from any physical book\nyou own. It's free and always will be.")
                .font(AppFont.emptyStateBody)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)

            Spacer()
                .frame(height: 32)

            // Mockup image — wider, clipped at bottom with gradient fade
            Image("welcome-mock")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)
                .mask(
                    VStack(spacing: 0) {
                        Rectangle()
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                    }
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)

            Spacer()

            // CTA button
            Button(action: onGetStarted) {
                Text("Start saving highlights")
                    .font(AppFont.buttonLabel)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule()
                            .fill(AppColor.buttonDark)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(0.55), value: appeared)

            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear { appeared = true }
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
}
