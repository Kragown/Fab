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
                
                Section("Données") {
                    Button(action: {
                        // Action pour exporter les données
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Exporter les données")
                        }
                    }
                    
                    Button(action: {
                        // Action pour supprimer les données
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Supprimer toutes les données")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // Ouvrir les conditions d'utilisation
                    }) {
                        HStack {
                            Text("Conditions d'utilisation")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // Ouvrir la politique de confidentialité
                    }) {
                        HStack {
                            Text("Politique de confidentialité")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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

