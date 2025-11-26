import SwiftUI

struct ContentView: View {
    @State private var decklists: [Decklist] = [
        Decklist(
            titre: "Assassin compétitif",
            heros: "Arakni",
            format: "Classic Constructed",
            date: Date()
        ),
        Decklist(
            titre: "Brute fun",
            heros: "Kayo",
            format: "Silver Age",
            date: Date().addingTimeInterval(-86400)
        ),
        Decklist(
            titre: "Guardian broken",
            heros: "Starvo",
            format: "Living Legend",
            date: Date().addingTimeInterval(-172800)
        )
    ]
    @State private var decklistToDelete: Decklist?
    @State private var showDeleteAlert: Bool = false
    @State private var showNewDecklistModal: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach($decklists) { $decklist in
                        NavigationLink(destination: DecklistDetailView(decklist: $decklist)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(decklist.titre)
                                    .font(.headline)
                                HStack {
                                    Text(decklist.heros)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(decklist.format)
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
                NewDecklistView(isPresented: $showNewDecklistModal, decklists: $decklists)
            }
        }
    }
    
    private func deleteDecklist() {
        if let decklist = decklistToDelete {
            decklists.removeAll { $0.id == decklist.id }
            decklistToDelete = nil
        }
    }
}

#Preview {
    ContentView()
}
