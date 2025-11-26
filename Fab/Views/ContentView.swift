import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var decklistService: DecklistService
    @State private var decklistToDelete: Decklist?
    @State private var showDeleteAlert: Bool = false
    @State private var showNewDecklistModal: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(decklistService.decklists) { decklist in
                        NavigationLink(destination: DecklistDetailView(
                            decklist: binding(for: decklist),
                            decklistService: decklistService
                        )) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(decklist.titre)
                                    .font(.headline)
                                HStack {
                                    Text(decklist.heros)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(decklist.format.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text(decklist.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onLongPressGesture {
                            decklistToDelete = decklist
                            showDeleteAlert = true
                        }
                    }
                }
                .navigationTitle("Decklist")
                .onAppear {
                    if let userId = authService.currentUser?.uid {
                        decklistService.fetchDecklists(userId: userId)
                    }
                }
                .onDisappear {
                    decklistService.stopListening()
                }
                .alert("Supprimer la Decklist", isPresented: $showDeleteAlert) {
                    Button("Annuler", role: .cancel) {
                        decklistToDelete = nil
                    }
                    Button("Supprimer", role: .destructive) {
                        deleteDecklist()
                    }
                } message: {
                    if let decklist = decklistToDelete {
                        Text("Êtes-vous sûr de vouloir supprimer \"\(decklist.titre)\" ? Cette action est irréversible.")
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showNewDecklistModal = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showNewDecklistModal) {
                NewDecklistView(isPresented: $showNewDecklistModal, decklistService: decklistService)
            }
        }
    }
    
    private func binding(for decklist: Decklist) -> Binding<Decklist> {
        guard let index = decklistService.decklists.firstIndex(where: { $0.id == decklist.id }) else {
            fatalError("Decklist not found")
        }
        return $decklistService.decklists[index]
    }
    
    private func deleteDecklist() {
        guard let decklist = decklistToDelete,
              let userId = authService.currentUser?.uid else {
            return
        }
        
        Task {
            do {
                try await decklistService.deleteDecklist(decklist, userId: userId)
                // Le listener devrait automatiquement mettre à jour la liste
            } catch {
                print("Erreur lors de la suppression: \(error)")
            }
        }
        
        decklistToDelete = nil
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
