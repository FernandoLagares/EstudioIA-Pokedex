import Foundation
import Combine

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [PokemonSummary] = []
    @Published var loadingState: LoadingState = .idle
    @Published var currentPage: Int = 0
    @Published var selectedPokemon: PokemonDetailResponse?
    @Published var detailLoadingState: LoadingState = .idle
    
    private let itemsPerPage = 20
    private var totalCount = 0
    
    func loadInitialPokemon() {
        currentPage = 0
        pokemonList = []
        loadPokemonPage(page: 0)
    }
    
    func loadPokemonPage(page: Int) {
        guard loadingState != .loading else { return }
        
        loadingState = .loading
        
        Task {
            do {
                let offset = page * itemsPerPage
                let response = try await PokemonService.shared.fetchPokemonList(
                    limit: itemsPerPage,
                    offset: offset
                )
                
                self.totalCount = response.count
                self.pokemonList = response.results
                self.currentPage = page
                self.loadingState = .success
                
            } catch {
                print("Error loading list: \(error)")
                self.loadingState = .error(error.localizedDescription)
            }
        }
    }
    
    func nextPage() {
        let maxPages = (totalCount + itemsPerPage - 1) / itemsPerPage
        if currentPage + 1 < maxPages {
            loadPokemonPage(page: currentPage + 1)
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            loadPokemonPage(page: currentPage - 1)
        }
    }
    
    func loadPokemonDetail(id: Int) {
        print("Loading detail for Pokemon ID: \(id)")
        detailLoadingState = .loading
        
        Task {
            do {
                print("Fetching from API...")
                let detail = try await PokemonService.shared.fetchPokemonDetail(id: id)
                print("Successfully fetched: \(detail.name)")
                self.selectedPokemon = detail
                self.detailLoadingState = .success
            } catch {
                print("Error loading detail: \(error)")
                self.detailLoadingState = .error(error.localizedDescription)
            }
        }
    }
    
    func retryDetailLoad() {
        if let pokemon = selectedPokemon {
            loadPokemonDetail(id: pokemon.id)
        }
    }
    
    func retryLoadList() {
        loadPokemonPage(page: currentPage)
    }
    
    func closePokemonDetail() {
        selectedPokemon = nil
        detailLoadingState = .idle
    }
}
