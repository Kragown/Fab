import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var decklistService = DecklistService()
    @StateObject private var heroService = HeroService()
    @StateObject private var themeService = ThemeService()
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                LoginView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authService.currentUser != nil)
        .environmentObject(authService)
        .environmentObject(decklistService)
        .environmentObject(heroService)
        .environmentObject(themeService)
        .preferredColorScheme(themeService.isDarkMode ? .dark : .light)
        .onAppear {
            heroService.fetchHeros()
        }
        .onChange(of: authService.currentUser) { oldValue, newValue in
            if newValue != nil {
                heroService.fetchHeros()
            }
        }
    }
}

#Preview {
    RootView()
}
