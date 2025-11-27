import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var decklistService: DecklistService
    
    private var userName: String {
        authService.userProfile?.userName ?? "Utilisateur"
    }
    
    private var userEmail: String {
        authService.userProfile?.email ?? authService.currentUser?.email ?? "utilisateur@example.com"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        )
                        .padding(.top, 20)
                    
                    Text(userName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Statistiques")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(decklistService.decklists.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Decklists")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paramètres")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            do {
                                try authService.logout()
                            } catch {
                                print("Erreur lors de la déconnexion: \(error)")
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Se déconnecter")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                if let userId = authService.currentUser?.uid {
                    decklistService.fetchDecklists(userId: userId)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

