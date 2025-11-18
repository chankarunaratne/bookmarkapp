//
//  SettingsMenuView.swift
//  bookmarkapp
//
//  Created as part of the settings/menu placeholder implementation.
//

import SwiftUI

struct SettingsMenuView: View {
    var body: some View {
        List {
            // Notifications section
            Section("Notifications") {
                NavigationLink {
                    PushNotificationsSettingsView()
                } label: {
                    HStack {
                        Text("Push Notifications")
                        Spacer()
                        Text("Off")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // About section
            Section("About") {
                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    Text("Terms of Service")
                }

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Text("Privacy Policy")
                }
            }

            // Session section
            Section("Session") {
                NavigationLink {
                    LogoutPlaceholderView()
                } label: {
                    Text("Log out")
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Placeholder Detail Screens

struct PushNotificationsSettingsView: View {
    @State private var isEnabled: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Enable push notifications", isOn: $isEnabled)
                    .disabled(true) // Placeholder – no real behavior yet
            } footer: {
                Text("Push notification settings will be available here in a future update.")
            }
        }
        .navigationTitle("Push Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title2.weight(.semibold))

                Text("The full Terms of Service will be displayed here and may open in a web page in a future version of the app.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2.weight(.semibold))

                Text("The full Privacy Policy will be displayed here and may open in a web page in a future version of the app.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogoutPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Log out")
                .font(.title2.weight(.semibold))

            Text("Logging out will be available here in a future update. For now, this is only a placeholder and does not change your account state.")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Log out")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsMenuView()
    }
}


