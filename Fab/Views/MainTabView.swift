import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("", systemImage: "list.bullet")
                }
            ProfileView()
                .tabItem {
                    Label("", systemImage: "person")
                }
            
            SettingsView()
                .tabItem {
                    Label("", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}
