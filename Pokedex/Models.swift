import Foundation

// MARK: - Lista de Pokémon
struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonSummary]
}

struct PokemonSummary: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String { name }
    
    var pokemonId: Int {
        let components = url.trimmingCharacters(in: CharacterSet(charactersIn: "/")).split(separator: "/")
        
        if let lastComponent = components.last {
            if let id = Int(lastComponent) {
                return id
            }
        }
        
        if components.count >= 2 {
            let secondLast = components[components.count - 2]
            if let id = Int(secondLast) {
                return id
            }
        }
        
        return 0
    }
}

// MARK: - Sprites
struct Sprites: Codable {
    let front_default: String?
    let front_shiny: String?
    let back_default: String?
    let back_shiny: String?
    let other: OtherSprites?
    
    var allSprites: [(name: String, url: String)] {
        var sprites: [(name: String, url: String)] = []
        
        if let url = other?.official_artwork?.front_default {
            sprites.append(("Official Artwork", url))
        }
        if let url = other?.official_artwork?.front_shiny {
            sprites.append(("Official Artwork Shiny", url))
        }
        if let url = other?.home?.front_default {
            sprites.append(("Home", url))
        }
        if let url = other?.home?.front_shiny {
            sprites.append(("Home Shiny", url))
        }
        if let url = front_default {
            sprites.append(("Front", url))
        }
        if let url = front_shiny {
            sprites.append(("Front Shiny", url))
        }
        if let url = back_default {
            sprites.append(("Back", url))
        }
        if let url = back_shiny {
            sprites.append(("Back Shiny", url))
        }
        
        return sprites
    }
}

struct OtherSprites: Codable {
    let official_artwork: OfficialArtwork?
    let home: Home?
}

struct OfficialArtwork: Codable {
    let front_default: String?
    let front_shiny: String?
}

struct Home: Codable {
    let front_default: String?
    let front_shiny: String?
}

// MARK: - Detalle de Pokémon
struct PokemonDetailResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [TypeSlot]
    
    struct TypeSlot: Codable {
        let type: TypeInfo
    }
    
    struct TypeInfo: Codable {
        let name: String
    }
}

// MARK: - Estados de la App
enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
