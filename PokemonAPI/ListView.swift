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
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                HStack(spacing: 8) {
                            // Red dot
                            Circle()
                                .fill(Color.red)
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
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Button(action: {
                    fetchPoke()
                    print("Button is clicked")
                }, label: {
                    Text("Fetch Pokemon")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 4)
                        .cornerRadius(10)
                })
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(results.indices, id: \.self) { index in
                            PokemonEntryView(pokemon: results[index], details: pokemonDetails[index])
                                .onAppear {
                                    fetchPokemonDetailsIfNeeded(for: results[index])
                                }
                        }
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 10)
                }
            }
            
            .background(Color.red)
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

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
