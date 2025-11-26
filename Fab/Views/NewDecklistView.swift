import SwiftUI

struct NewDecklistView: View {
    @Binding var isPresented: Bool
    @Binding var decklists: [Decklist]
    
    @State private var titre: String = ""
    @State private var heros: String = ""
    @State private var format: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Titre", text: $titre)
                    TextField("Héros", text: $heros)
                    TextField("Format", text: $format)
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
                    Button("Créer") {
                        createDecklist()
                    }
                    .disabled(titre.isEmpty || heros.isEmpty || format.isEmpty)
                }
            }
        }
    }
    
    private func createDecklist() {
        let newDecklist = Decklist(
            titre: titre,
            heros: heros,
            format: format,
            date: date
        )
        decklists.append(newDecklist)
        isPresented = false
        resetForm()
    }
    
    private func resetForm() {
        titre = ""
        heros = ""
        format = ""
        date = Date()
    }
}

#Preview {
    NewDecklistView(
        isPresented: .constant(true),
        decklists: .constant([])
    )
}

