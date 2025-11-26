import Foundation

enum GameFormat: String, Codable, CaseIterable {
    case classicConstructed = "Classic Constructed"
    case livingLegend = "Living Legend"
    case silverAge = "Silver Age"
    
    var displayName: String {
        return self.rawValue
    }
}

struct Decklist: Identifiable, Codable {
    let id: UUID
    var titre: String
    var heros: String
    var format: GameFormat
    var date: Date
    
    init(id: UUID = UUID(), titre: String, heros: String, format: GameFormat, date: Date = Date()) {
        self.id = id
        self.titre = titre
        self.heros = heros
        self.format = format
        self.date = date
    }
}

