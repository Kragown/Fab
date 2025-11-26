import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var decklistService = DecklistService()
    
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
    }
}

#Preview {
    RootView()
}
