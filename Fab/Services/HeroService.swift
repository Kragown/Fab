import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class HeroService: ObservableObject {
    @Published var heros: [Hero] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    
    func fetchHeros() {
        listener?.remove()
                
        listener = db.collection("heros")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Erreur lors de la récupération des héros: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Snapshot est nil")
                    return
                }
                                
                var newHeros: [Hero] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let heroClass = data["class"] as? String else {
                        print("⚠️ Document \(doc.documentID) ignoré: champs 'name' ou 'class' manquants")
                        continue
                    }
                                        
                    let hero = Hero(
                        id: doc.documentID,
                        name: name,
                        class: heroClass,
                        imageURL: nil
                    )
                    newHeros.append(hero)
                }
                
                DispatchQueue.main.async {
                    self?.heros = newHeros.sorted { $0.name < $1.name }
                }
                
                Task {
                    await self?.loadImageURLs(for: newHeros)
                }
            }
    }
    
    private func loadImageURLs(for heros: [Hero]) async {
        for hero in heros {
            do {
                let doc = try await db.collection("heros").document(hero.id).getDocument()
                guard let data = doc.data(),
                      let imagePath = data["image"] as? String else {
                    continue
                }
                
                var cleanPath = imagePath
                if imagePath.contains("firebasestorage.app/") {
                    cleanPath = String(imagePath.split(separator: "/").last ?? "")
                } else if imagePath.hasPrefix("gs://") {
                    cleanPath = String(imagePath.split(separator: "/").last ?? "")
                }
                
                if !cleanPath.hasPrefix("http") {
                    if let url = await getDownloadURL(for: cleanPath) {
                        await MainActor.run {
                            if let index = self.heros.firstIndex(where: { $0.id == hero.id }) {
                                self.heros[index].imageURL = url
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        if let index = self.heros.firstIndex(where: { $0.id == hero.id }) {
                            self.heros[index].imageURL = cleanPath
                        }
                    }
                }
            } catch {
                print("Erreur lors du chargement de l'image pour \(hero.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func getDownloadURL(for path: String) async -> String? {
        do {
            let storageRef = storage.reference().child(path)
            
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("Erreur lors de la récupération de l'URL pour \(path): \(error.localizedDescription)")
            return nil
        }
    }
    
    func getImageURL(for hero: Hero) async -> String? {
        if let url = hero.imageURL, url.hasPrefix("http") {
            return url
        }
        
        do {
            let doc = try await db.collection("heros").document(hero.id).getDocument()
            guard let data = doc.data(),
                  let imagePath = data["image"] as? String else {
                return nil
            }
            
            var cleanPath = imagePath
            if imagePath.contains("firebasestorage.app/") {
                cleanPath = String(imagePath.split(separator: "/").last ?? "")
            } else if imagePath.hasPrefix("gs://") {
                cleanPath = String(imagePath.split(separator: "/").last ?? "")
            }
            
            return await getDownloadURL(for: cleanPath)
        } catch {
            print("Erreur lors de la récupération de l'image pour \(hero.name): \(error.localizedDescription)")
            return nil
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

