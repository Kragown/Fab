import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authService)
    }
}

#Preview {
    RootView()
}
