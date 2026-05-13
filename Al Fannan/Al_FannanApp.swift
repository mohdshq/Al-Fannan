import SwiftUI

@main
struct Al_FannanApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        hasSeenOnboarding = true
                        showOnboarding = false
                    }
                }
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
        }
    }
}
