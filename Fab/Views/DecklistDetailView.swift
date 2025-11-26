import SwiftUI
import FirebaseAuth

struct DecklistDetailView: View {
    @Binding var decklist: Decklist
    @ObservedObject var decklistService: DecklistService
    @State private var isEditing: Bool = false
    @State private var editedTitre: String = ""
    @State private var editedHeros: String = ""
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
                
                VStack(alignment: .leading, spacing: 12) {
                    if isEditing {
                        EditableInfoRow(label: "Héros", value: $editedHeros)
                        EditableFormatRow(label: "Format", format: $editedFormat)
                        EditableDateRow(label: "Date", date: $editedDate)
                    } else {
                        InfoRow(label: "Héros", value: decklist.heros)
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
        editedHeros = decklist.heros
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
        decklist.heros = editedHeros
        decklist.format = editedFormat
        decklist.date = editedDate
        
        do {
            try await decklistService.updateDecklist(decklist, userId: userId)
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            // Restaurer les valeurs en cas d'erreur
            startEditing()
        }
        
        isLoading = false
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
                heros: "Arakni",
                format: .classicConstructed,
                date: Date()
            )),
            decklistService: DecklistService()
        )
    }
}
