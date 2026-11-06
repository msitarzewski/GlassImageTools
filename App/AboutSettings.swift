import SwiftUI

/// Settings → About, AutoPaper's About pane on visionOS: the icon, name and version, what the app is for and who
/// made it, the website's home, privacy and help pages, and the license.
struct AboutSettings: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Tools/GenerateIcon.swift writes this flat composite of the icon's three layers.
                Image("AboutIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(.circle)
                    .accessibilityHidden(true)
                Text("Glass Image Tools")
                    .font(.title2.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Text("Version \(Self.version) (\(Self.build))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .accessibilityIdentifier("about-version")
                VStack(spacing: 8) {
                    Text("Crop a Vision Pro screenshot, mark it up, and paste it, without taking the headset off.")
                    Text("Michael Sitarzewski made it for exactly that, and shares it free in case it’s useful to you too.")
                }
                .font(.callout)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 420)
                .padding(.top, 4)
                HStack(spacing: 12) {
                    Link("Website", destination: Website.home)
                    Link("Privacy", destination: Website.privacy)
                    Link("Help", destination: Website.help)
                }
                .padding(.top, 4)
                Text("MIT · © 2026 Michael Sitarzewski")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal)
        }
        .navigationTitle("About")
        .accessibilityIdentifier("about-settings")
    }

    private static func infoString(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "–"
    }
    private static let version = infoString("CFBundleShortVersionString")
    private static let build = infoString("CFBundleVersion")
}

/// The project website, built from `site/` and published with GitHub Pages; Settings → About links to it.
enum Website {
    static let home = URL(string: "https://msitarzewski.github.io/GlassImageTools/")!
    static let privacy = home.appending(path: "privacy.html")
    static let help = home.appending(path: "help.html")
}
