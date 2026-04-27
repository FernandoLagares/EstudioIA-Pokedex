import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    switch viewModel.loadingState {
                    case .loading:
                        LoadingView()
                    case .error(let message):
                        ErrorView(message: message, retryAction: {
                            viewModel.retryLoadList()
                        })
                    case .success, .idle:
                        if viewModel.pokemonList.isEmpty {
                            EmptyStateView()
                        } else {
                            PokemonListView(viewModel: viewModel)
                        }
                    }
                }
                .navigationTitle("Pokédex")
            }
            
            if let pokemon = viewModel.selectedPokemon {
                PokemonDetailSheet(
                    pokemon: pokemon,
                    loadingState: viewModel.detailLoadingState,
                    onClose: { viewModel.closePokemonDetail() },
                    onRetry: { viewModel.retryDetailLoad() }
                )
            }
        }
        .onAppear {
            viewModel.loadInitialPokemon()
        }
    }
}

struct PokemonListView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var maxPages: Int {
        let totalCount = 1025
        return (totalCount + 19) / 20
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.pokemonList) { pokemon in
                        Button(action: {
                            viewModel.loadPokemonDetail(id: pokemon.pokemonId)
                        }) {
                            PokemonCardView(pokemon: pokemon)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: { viewModel.previousPage() }) {
                    Label("Anterior", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.currentPage == 0)
                .buttonStyle(.bordered)
                
                Text("Página \(viewModel.currentPage + 1) de \(maxPages)")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                
                Button(action: { viewModel.nextPage() }) {
                    Label("Siguiente", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.currentPage >= maxPages - 1)
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

struct PokemonCardView: View {
    let pokemon: PokemonSummary
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Color(.systemGray6)
                
                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.pokemonId).png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } placeholder: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(height: 100)
            }
            .frame(height: 100)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                Text("#\(String(format: "%03d", pokemon.pokemonId))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando Pokémon...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error al cargar")
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Label("Reintentar", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Sin Pokémon")
                .font(.headline)
            
            Text("No hay Pokémon para mostrar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct PokemonDetailSheet: View {
    let pokemon: PokemonDetailResponse
    let loadingState: LoadingState
    let onClose: () -> Void
    let onRetry: () -> Void
    
    var imageURL: String? {
            if let officialArt = pokemon.sprites.other?.official_artwork?.front_default {
                return officialArt
            }
            return pokemon.sprites.front_default
        }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
            
            VStack(spacing: 0) {
                HStack {
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                switch loadingState {
                case .loading:
                    VStack {
                        ProgressView()
                        Text("Cargando detalles...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                    
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        
                        Text("Error al cargar detalles")
                            .font(.headline)
                        
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: onRetry) {
                            Label("Reintentar", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    
                case .success, .idle:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Imagen principal (Official Artwork)
                            if let imageURLString = imageURL {
                                AsyncImage(url: URL(string: imageURLString)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 200)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            Divider()
                            
                            // Galería de Sprites
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sprites")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(pokemon.sprites.allSprites, id: \.name) { sprite in
                                            VStack(spacing: 4) {
                                                AsyncImage(url: URL(string: sprite.url)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 80)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(height: 80)
                                                }
                                                
                                                Text(sprite.name)
                                                    .font(.caption2)
                                                    .lineLimit(1)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(width: 100)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal, -16)
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            Divider()
                            
                            // ID
                            HStack {
                                Text("ID:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("#\(String(format: "%03d", pokemon.id))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            // Tipos
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tipos")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 8) {
                                    ForEach(pokemon.types, id: \.type.name) { typeSlot in
                                        Text(typeSlot.type.name.capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    Spacer()
                                }
                            }
                            
                            Divider()
                            
                            // Altura y Peso
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Altura")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Double(pokemon.height) / 10, specifier: "%.1f") m")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Peso")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Double(pokemon.weight) / 10, specifier: "%.1f") kg")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding()
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PokemonViewModel())
}
