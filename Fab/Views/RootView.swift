import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var decklistService = DecklistService()
    @StateObject private var heroService = HeroService()
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authService)
        .environmentObject(decklistService)
        .environmentObject(heroService)
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
