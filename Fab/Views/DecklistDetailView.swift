import SwiftUI
import FirebaseAuth

struct DecklistDetailView: View {
    @Binding var decklist: Decklist
    @ObservedObject var decklistService: DecklistService
    @EnvironmentObject var heroService: HeroService
    @State private var isEditing: Bool = false
    @State private var editedTitre: String = ""
    @State private var editedHeroId: String = ""
    @State private var editedFormat: GameFormat = .classicConstructed
    @State private var editedDate: Date = Date()
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    TextField("Titre", text: $editedTitre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    Text(decklist.titre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Divider()
                
                if !isEditing, let hero = heroService.heros.first(where: { $0.id == decklist.heroId }) {
                    HStack {
                        HeroImageView(heroId: decklist.heroId, heroService: heroService)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading) {
                            Text(hero.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(hero.class)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if isEditing {
                        EditableHeroRow(label: "Héros", selectedHeroId: $editedHeroId, heroService: heroService)
                        EditableFormatRow(label: "Format", format: $editedFormat)
                        EditableDateRow(label: "Date", date: $editedDate)
                    } else {
                        InfoRow(label: "Héros", value: heroName(for: decklist.heroId))
                        InfoRow(label: "Format", value: decklist.format.displayName)
                        InfoRow(label: "Date", value: decklist.date, style: .date)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Sauvegarder") {
                            Task {
                                await saveChanges()
                            }
                        }
                    }
                } else {
                    Button("Modifier") {
                        startEditing()
                    }
                }
            }
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startEditing() {
        editedTitre = decklist.titre
        editedHeroId = decklist.heroId
        editedFormat = decklist.format
        editedDate = decklist.date
        isEditing = true
    }
    
    private func saveChanges() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Utilisateur non connecté"
            showError = true
            return
        }
        
        isLoading = true
        
        decklist.titre = editedTitre
        decklist.heroId = editedHeroId
        decklist.format = editedFormat
        decklist.date = editedDate
        
        do {
            try await decklistService.updateDecklist(decklist, userId: userId)
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            startEditing()
        }
        
        isLoading = false
    }
    
    private func heroName(for heroId: String) -> String {
        heroService.heros.first(where: { $0.id == heroId })?.name ?? heroId
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var date: Date?
    var style: Text.DateStyle?
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    init(label: String, value: Date, style: Text.DateStyle) {
        self.label = label
        self.value = ""
        self.date = value
        self.style = style
    }
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            if let date = date, let style = style {
                Text(date, style: style)
                    .font(.body)
            } else {
                Text(value)
                    .font(.body)
            }
        }
    }
}

struct EditableInfoRow: View {
    let label: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            TextField(label, text: $value)
                .multilineTextAlignment(.trailing)
                .font(.body)
        }
    }
}

struct EditableHeroRow: View {
    let label: String
    @Binding var selectedHeroId: String
    @ObservedObject var heroService: HeroService
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Picker("", selection: $selectedHeroId) {
                Text("Sélectionner un héros").tag("")
                ForEach(heroService.heros) { hero in
                    Text(hero.name).tag(hero.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200, alignment: .trailing)
        }
    }
}

struct EditableFormatRow: View {
    let label: String
    @Binding var format: GameFormat
    
    var body: some View {
        HStack(alignment: .center) {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Spacer()
            Picker("", selection: $format) {
                ForEach(GameFormat.allCases, id: \.self) { gameFormat in
                    Text(gameFormat.displayName)
                        .tag(gameFormat)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200, alignment: .trailing)
        }
    }
}

struct EditableDateRow: View {
    let label: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
        }
    }
}

#Preview {
    NavigationView {
        DecklistDetailView(
            decklist: .constant(Decklist(
                titre: "Assassin compétitif",
                heroId: "fILGcOvNAUHOPK3eYRVj",
                format: .classicConstructed,
                date: Date()
            )),
            decklistService: DecklistService()
        )
        .environmentObject(HeroService())
    }
}
