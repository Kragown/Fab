import Foundation

struct Decklist: Identifiable, Codable {
    let id: UUID
    var titre: String
    var heros: String
    var format: String
    var date: Date
    
    init(id: UUID = UUID(), titre: String, heros: String, format: String, date: Date = Date()) {
        self.id = id
        self.titre = titre
        self.heros = heros
        self.format = format
        self.date = date
    }
}

