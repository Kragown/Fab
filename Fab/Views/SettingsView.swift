import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var notificationsEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Notifications") {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                }
                
                Section("Apparence") {
                    Toggle("Mode sombre", isOn: $themeService.isDarkMode)
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeService())
}

