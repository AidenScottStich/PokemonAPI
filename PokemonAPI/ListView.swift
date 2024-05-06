import SwiftUI

struct Images: Codable {
    let front_default: String
}

struct PokemonDetails: Codable {
    let id: Int
    let sprites: Images
}

struct Poke: Codable, Identifiable {
    let id = UUID()
    let name: String
    let url: URL
}

struct PokeResponse: Codable {
    let results: [Poke]
}

struct ListView: View {
    @State private var results: [Poke] = []
    @State private var pokemonDetails: [PokemonDetails?] = []
    @State private var showPokemon = false
    @State private var data: ApiResponse? = nil
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                HStack(spacing: 8) {
                    // Red dot
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    
                    // Green dot
                    Circle()
                        .fill(Color.green)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    
                    // Blue dot
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                }
                Text("Pokedex list")
                    .font(.title)
                    .fontWeight(.bold)
                Button(action: {
                    fetchPoke()
                    print("Button is clicked")
                }, label: {
                    Text("Fetch Pokemon")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .border(Color.black, width: 4)
                        .cornerRadius(10)
                })
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(results.indices, id: \.self) { index in
                            PokemonEntryView(pokemon: results[index], details: pokemonDetails[index])
                                .onAppear {
                                    fetchPokemonDetailsIfNeeded(for: results[index])
                                }.onTapGesture {
                                    showPokemon.toggle()
                                    print(pokemonDetails[index])
                                    
                                    if let pokemon = pokemonDetails[index] {
                                        let selectedId = String(pokemon.id)
                                        fetchSingleData(selectedId: selectedId) { result in
                                            switch result {
                                            case .success(let result):
                                                
                                                data = result
                                            case .failure(let error):
                                                // Handle the error
                                                print("Error: \(error)")
                                            }
                                        }
                                    }
                                    
                                    
                                }
                        }
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .border(Color.black, width: 10)
                }
            }
            
            .background(Color.red)
        }        .sheet(isPresented: $showPokemon) {
            if let pokemonData = data {
                PokemonCard(pokemon: pokemonData)
            }
        }
    }
    
    func fetchPoke() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/?limit=100") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let pokeResponse = try decoder.decode(PokeResponse.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.results = pokeResponse.results
                        self.pokemonDetails = Array(repeating: nil, count: pokeResponse.results.count)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchPokemonDetailsIfNeeded(for poke: Poke) {
        guard let url = URL(string: poke.url.absoluteString) else {
            print("Invalid Pokemon URL")
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let pokemonDetails = try decoder.decode(PokemonDetails.self, from: jsonData)
                    DispatchQueue.main.async {
                        if let index = results.firstIndex(where: { $0.id == poke.id }) {
                            self.pokemonDetails[index] = pokemonDetails
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    func fetchSingleData(selectedId: String, completion: @escaping (Result<ApiResponse, Error>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(selectedId.lowercased())") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(ApiResponse.self, from: responseData)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}


struct PokemonEntryView: View {
    let pokemon: Poke
    let details: PokemonDetails?
    
    var body: some View {
        VStack {
            if let imageURL = details?.sprites.front_default, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(width: 100, height: 100)
            }
            
            Text(pokemon.name.capitalized)
                .font(.headline)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

#Preview {
    ListView()
}
