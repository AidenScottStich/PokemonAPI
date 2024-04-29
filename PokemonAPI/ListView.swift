import SwiftUI

struct Images: Codable {
    let front_default: String
}

struct PokemonDetails: Codable {
    let id: Int
    let sprites: Images // Change sprites to be of type Images
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
        VStack {
            Button(action: {
                fetchPoke()
                print("Button is clicked")
            }, label: {
                Text("Fetch Pokemon")
            })
            
            ScrollView {
                LazyVStack {
                    ForEach(results.indices, id: \.self) { index in
                        VStack {
                            Text(results[index].name)
                                .font(.title)
                            if let details = pokemonDetails[index] {
                                if let imageURL = URL(string: details.sprites.front_default) {
                                    // Display the image using URL
                                    AsyncImage(url: imageURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        case .failure:
                                            ProgressView()
                                        @unknown default:
                                            ProgressView()
                                        }
                                    }
                                    .frame(width: 100, height: 100) // Adjust size as needed
                                }
                                
                                // You can add more details as needed
                            } else {
                                ProgressView()
                                    .onAppear {
                                        // Fetch details when the view appears
                                        fetchPokemonDetails(for: results[index])
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .padding()
    }
    
    // Function to fetch details for a specific Pokemon
       func fetchPokemonDetails(for poke: Poke) {
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
                           // Find the index of the Poke in results array and update corresponding pokemonDetails
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
                        self.pokemonDetails = Array(repeating: nil, count: pokeResponse.results.count) // Initialize pokemonDetails array
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
