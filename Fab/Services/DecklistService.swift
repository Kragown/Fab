import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class DecklistService: ObservableObject {
    @Published var decklists: [Decklist] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchDecklists(userId: String) {
        listener?.remove()
                
        listener = db.collection("decklists")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Erreur lors de la récupération des decklists: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Snapshot est nil")
                    return
                }
                                
                let newDecklists = snapshot.documents.compactMap { doc -> Decklist? in
                    let data = doc.data()
                    guard let titre = data["titre"] as? String,
                          let heros = data["heros"] as? String,
                          let formatString = data["format"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }
                    
                    // Convertir le String en GameFormat, avec une valeur par défaut si invalide
                    let format = GameFormat(rawValue: formatString) ?? .classicConstructed
                    
                    let idString = doc.documentID
                    let uuid = UUID(uuidString: idString) ?? UUID()
                    
                    return Decklist(
                        id: uuid,
                        titre: titre,
                        heros: heros,
                        format: format,
                        date: timestamp.dateValue()
                    )
                }
                
                let sortedDecklists = newDecklists.sorted { $0.date > $1.date }
                                
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                    self?.decklists = sortedDecklists
                }
            }
    }
    
    func createDecklist(_ decklist: Decklist, userId: String) async throws {
        guard Auth.auth().currentUser?.uid == userId else {
            throw NSError(domain: "DecklistService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté"])
        }
        
        let decklistData: [String: Any] = [
            "titre": decklist.titre,
            "heros": decklist.heros,
            "format": decklist.format.rawValue,
            "date": Timestamp(date: decklist.date),
            "userId": userId
        ]
        
        let docId = decklist.id.uuidString
        try await db.collection("decklists").document(docId).setData(decklistData)
    }
    
    func updateDecklist(_ decklist: Decklist, userId: String) async throws {
        guard Auth.auth().currentUser?.uid == userId else {
            throw NSError(domain: "DecklistService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Accès non autorisé"])
        }
        
        let docId = decklist.id.uuidString
        try await db.collection("decklists").document(docId).updateData([
            "titre": decklist.titre,
            "heros": decklist.heros,
            "format": decklist.format.rawValue,
            "date": Timestamp(date: decklist.date)
        ])
    }
    
    func deleteDecklist(_ decklist: Decklist, userId: String) async throws {
        guard Auth.auth().currentUser?.uid == userId else {
            throw NSError(domain: "DecklistService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Accès non autorisé"])
        }
        
        let docId = decklist.id.uuidString
        try await db.collection("decklists").document(docId).delete()
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

