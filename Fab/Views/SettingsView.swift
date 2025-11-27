import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Notifications") {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                }
                
                Section("Apparence") {
                    Toggle("Mode sombre", isOn: $darkModeEnabled)
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
}

