import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var decklistService: DecklistService
    @EnvironmentObject var heroService: HeroService
    @State private var decklistToDelete: Decklist?
    @State private var showDeleteAlert: Bool = false
    @State private var showNewDecklistModal: Bool = false
    @State private var selectedFormat: GameFormat? = nil
    @State private var selectedHeroId: String? = nil
    
    // Liste filtrée des decklists
    private var filteredDecklists: [Decklist] {
        var filtered = decklistService.decklists
        
        if let format = selectedFormat {
            filtered = filtered.filter { $0.format == format }
        }
        
        if let heroId = selectedHeroId {
            filtered = filtered.filter { $0.heroId == heroId }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(filteredDecklists) { decklist in
                        NavigationLink(destination: DecklistDetailView(
                            decklist: binding(for: decklist),
                            decklistService: decklistService
                        )) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(decklist.titre)
                                        .font(.headline)
                                    HStack {
                                        Text(decklist.format.displayName)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    Text(decklist.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HeroImageView(heroId: decklist.heroId, heroService: heroService)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: {
                                selectedFormat = nil
                            }) {
                                HStack {
                                    Text("Tous les formats")
                                    if selectedFormat == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ForEach(GameFormat.allCases, id: \.self) { format in
                                Button(action: {
                                    selectedFormat = format
                                }) {
                                    HStack {
                                        Text(format.displayName)
                                        if selectedFormat == format {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                if selectedFormat != nil {
                                    Text(selectedFormat?.displayName ?? "")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                selectedHeroId = nil
                            }) {
                                HStack {
                                    Text("Tous les héros")
                                    if selectedHeroId == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ForEach(heroService.heros) { hero in
                                Button(action: {
                                    selectedHeroId = hero.id
                                }) {
                                    HStack {
                                        Text(hero.name)
                                        if selectedHeroId == hero.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "person.3.fill")
                                if let heroId = selectedHeroId,
                                   let hero = heroService.heros.first(where: { $0.id == heroId }) {
                                    Text(hero.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
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
            } catch {
                print("Erreur lors de la suppression: \(error)")
            }
        }
        
        decklistToDelete = nil
    }
    
    private func heroName(for heroId: String) -> String {
        heroService.heros.first(where: { $0.id == heroId })?.name ?? heroId
    }
}

struct HeroImageView: View {
    let heroId: String
    @ObservedObject var heroService: HeroService
    @State private var imageURL: String?
    
    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let hero = heroService.heros.first(where: { $0.id == heroId }) else {
            return
        }
        
        if let url = hero.imageURL {
            imageURL = url
        } else {
            // Si l'URL n'est pas encore chargée, essayer de la récupérer
            if let url = await heroService.getImageURL(for: hero) {
                imageURL = url
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
