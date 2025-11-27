import Foundation

struct Hero: Identifiable, Codable {
    let id: String
    let name: String
    let `class`: String
    var imageURL: String? // URL de téléchargement depuis Firebase Storage
    
    init(id: String, name: String, class: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.`class` = `class`
        self.imageURL = imageURL
    }
}

