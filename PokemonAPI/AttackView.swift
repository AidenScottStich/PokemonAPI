import SwiftUI

struct AttackView: View {
    @State private var pokemon1: ApiResponse? = nil
    @State private var pokemon2: ApiResponse? = nil
    @State private var winner: ApiResponse?
    @State private var showResult = false
    @State private var reloadPage = false
    

    var body: some View {
        VStack {
            if let pokemon1 = pokemon1, let pokemon2 = pokemon2 {
                
                Text(pokemon1.name)
                
                AsyncImage(url: URL(string: pokemon1.sprites.front_default)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 250, height: 250)
                
                Text(pokemon2.name)
                
                AsyncImage(url: URL(string: pokemon2.sprites.front_default)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 250, height: 250)

                
                Button(action: {
                    battle()
                }) {
                    Text("Battle!")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                if let winner = winner {
                    Text("Winner: \(winner.name)")
                        .font(.headline)
                        .padding()
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            fetchRandomPokemons()
        }
        .sheet(isPresented: $showResult) {
            if let winner = winner {
                
                Text("\(winner.name) wins!")
                
                AsyncImage(url: URL(string: winner.sprites.front_default)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 300, height: 300)
                
                Button(action: {
                                resetPage()
                            }) {
                                Text("Reset")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
            }
        }
        .id(reloadPage) // Reloads the view when reloadPage changes
    }
    
    func fetchRandomPokemons() {
        let randomId1 = Int.random(in: 1...1000)
        let randomId2 = Int.random(in: 1...1000)
        fetchPokemon(id: randomId1) { pokemon in
            self.pokemon1 = pokemon
        }
        fetchPokemon(id: randomId2) { pokemon in
            self.pokemon2 = pokemon
        }
    }
    
    func resetPage() {
        pokemon1 = nil
        pokemon2 = nil
        winner = nil
        showResult = false
        reloadPage.toggle()
    }
    
    func fetchPokemon(id: Int, completion: @escaping (ApiResponse) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let pokemonDetails = try decoder.decode(ApiResponse.self, from: jsonData)
                    DispatchQueue.main.async {
                        completion(pokemonDetails)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func battle() {
        guard let pokemon1 = pokemon1, let pokemon2 = pokemon2 else { return }
        let winnerIndex = Int.random(in: 0...1)
        winner = winnerIndex == 0 ? pokemon1 : pokemon2
        showResult = true
    }
}

struct AttackView_Previews: PreviewProvider {
    static var previews: some View {
        AttackView()
    }
}
