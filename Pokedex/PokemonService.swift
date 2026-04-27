import Foundation

class PokemonService {
    static let shared = PokemonService()
    
    private let baseURL = "https://pokeapi.co/api/v2"
    
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse {
        let urlString = "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(PokemonListResponse.self, from: data)
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        let urlString = "\(baseURL)/pokemon/\(id)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        
        print("Fetching URL (no cache): \(urlString)")
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(PokemonDetailResponse.self, from: data)
    }

}
