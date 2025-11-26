import SwiftUI

struct DecklistDetailView: View {
    @Binding var decklist: Decklist
    @State private var isEditing: Bool = false
    @State private var editedTitre: String = ""
    @State private var editedHeros: String = ""
    @State private var editedFormat: String = ""
    @State private var editedDate: Date = Date()
    
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
                        EditableInfoRow(label: "Format", value: $editedFormat)
                        EditableDateRow(label: "Date", date: $editedDate)
                    } else {
                        InfoRow(label: "Héros", value: decklist.heros)
                        InfoRow(label: "Format", value: decklist.format)
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
                    Button("Sauvegarder") {
                        saveChanges()
                    }
                } else {
                    Button("Modifier") {
                        startEditing()
                    }
                }
            }
        }
    }
    
    private func startEditing() {
        editedTitre = decklist.titre
        editedHeros = decklist.heros
        editedFormat = decklist.format
        editedDate = decklist.date
        isEditing = true
    }
    
    private func saveChanges() {
        decklist.titre = editedTitre
        decklist.heros = editedHeros
        decklist.format = editedFormat
        decklist.date = editedDate
        isEditing = false
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
                format: "Classic Constructed",
                date: Date()
            ))
        )
    }
}
