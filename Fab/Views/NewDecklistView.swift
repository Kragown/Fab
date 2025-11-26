import SwiftUI
import FirebaseAuth

struct NewDecklistView: View {
    @Binding var isPresented: Bool
    @ObservedObject var decklistService: DecklistService
    
    @State private var titre: String = ""
    @State private var heros: String = ""
    @State private var format: GameFormat = .classicConstructed
    @State private var date: Date = Date()
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Titre", text: $titre)
                    TextField("Héros", text: $heros)
                    Picker("Format", selection: $format) {
                        ForEach(GameFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Nouvelle Decklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Créer") {
                            Task {
                                await createDecklist()
                            }
                        }
                        .disabled(titre.isEmpty || heros.isEmpty)
                    }
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createDecklist() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Utilisateur non connecté"
            showError = true
            return
        }
        
        isLoading = true
        
        let newDecklist = Decklist(
            titre: titre,
            heros: heros,
            format: format,
            date: date
        )
        
        do {
            try await decklistService.createDecklist(newDecklist, userId: userId)
            isPresented = false
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func resetForm() {
        titre = ""
        heros = ""
        format = .classicConstructed
        date = Date()
    }
}

#Preview {
    NewDecklistView(
        isPresented: .constant(true),
        decklistService: DecklistService()
    )
}

