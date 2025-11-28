import SwiftUI
import FirebaseAuth

struct NewDecklistView: View {
    @Binding var isPresented: Bool
    @ObservedObject var decklistService: DecklistService
    @EnvironmentObject var heroService: HeroService
    
    @State private var titre: String = ""
    @State private var selectedHeroId: String = ""
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
                        .animation(.easeInOut(duration: 0.2), value: titre)
                    Picker("Héros", selection: $selectedHeroId) {
                        Text("Sélectionner un héros").tag("")
                        ForEach(heroService.heros) { hero in
                            Text(hero.name).tag(hero.id)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedHeroId)
                    .onAppear {
                        if heroService.heros.isEmpty {
                            heroService.fetchHeros()
                        } else {
                            print("\(heroService.heros.count) héros disponibles dans le picker")
                        }
                    }
                    Picker("Format", selection: $format) {
                        ForEach(GameFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: format)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .animation(.easeInOut(duration: 0.2), value: date)
                }
            }
            .navigationTitle("Nouvelle Decklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
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
                        .disabled(titre.isEmpty || selectedHeroId.isEmpty)
                        .animation(.easeInOut(duration: 0.2), value: titre.isEmpty || selectedHeroId.isEmpty)
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
            heroId: selectedHeroId,
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
        selectedHeroId = ""
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

