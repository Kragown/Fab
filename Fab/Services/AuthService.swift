import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthService: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: UserProfile?
    
    private let db = Firestore.firestore()
    private var authStateListener: NSObjectProtocol?
    
    init() {
        // Écouter les changements d'authentification
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            if let user = user {
                Task {
                    await self?.fetchUserProfile(userId: user.uid)
                }
            } else {
                self?.userProfile = nil
            }
        }
    }
    
    // MARK: - Authentication
    
    // Inscription avec email/mot de passe
    func register(email: String, password: String, userName: String) async throws {
        // 1. Créer l'utilisateur dans Firebase Auth
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // 2. Créer le profil utilisateur dans Firestore
        try await db.collection("users").document(result.user.uid).setData([
            "email": email,
            "userName": userName,
            "createdAt": Timestamp()
        ])
        
        // Le listener va automatiquement charger le profil
    }
    
    // Connexion avec email/mot de passe
    func login(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
        // Le listener dans init() va automatiquement charger le profil
    }
    
    // Déconnexion
    func logout() throws {
        try Auth.auth().signOut()
        self.userProfile = nil
    }
    
    // Récupérer le profil utilisateur depuis Firestore
    private func fetchUserProfile(userId: String) async {
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            
            if let data = doc.data() {
                self.userProfile = UserProfile(
                    id: userId,
                    email: data["email"] as? String ?? "",
                    userName: data["userName"] as? String ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
        } catch {
            print("Erreur lors de la récupération du profil: \(error)")
        }
    }
}

// Modèle pour le profil utilisateur dans Firestore
struct UserProfile: Codable {
    let id: String
    let email: String
    let userName: String
    let createdAt: Date
}
