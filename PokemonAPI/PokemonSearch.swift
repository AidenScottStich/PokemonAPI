//
//  PokemonSearch.swift
//  PokemonAPI
//
//  Created by SUN, JOHNNY on 4/24/24.
//
 
import SwiftUI

struct PokemonSearch: View {
    @State private var inputName = ""
    @State private var hasResult = false
    @State private var showPokemon = false
    @State private var errorText = ""
    @State private var data: ApiResponse? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Pokémon Search")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
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
                Text("Input a Pokémon name")
                    .foregroundColor(.white)
                    .font(.title2)
                TextField("Pokemon Name", text: $inputName)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 5))
                    .padding([.leading, .trailing], 50)
                    
                
                Button(action: {
                    fetchData()
                }, label: {
                    Text("Search")
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 4)
                        .cornerRadius(10)
                })
                .padding()
                
                Spacer()
                
                if hasResult {
                    Text("Name: \(data?.name ?? "")")
                    
                    if let types = data?.types {
                        let typeNames = types.map { $0.type.name }.joined(separator: ", ")
                        Text("Type: \(typeNames)")
                    }
                    
                    AsyncImage(url: URL(string: data?.sprites.front_default ?? "")) { phase in
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
                    .onTapGesture {
                        showPokemon.toggle()
                    }
                } else {
                    Text(errorText)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.red)
        }
        .sheet(isPresented: $showPokemon) {
            if let pokemonData = data {
                PokemonCard(pokemon: pokemonData)
            }
        }
        
    }
    
    func fetchData() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(inputName.lowercased())") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let apiData = data {
                do {
                    let decodedData = try JSONDecoder().decode(ApiResponse.self, from: apiData)
                    DispatchQueue.main.async {
                        self.data = decodedData
                        self.hasResult = true
                    }
                } catch {
                    self.hasResult = false
                    print("Error decoding JSON: \(error)")
                    self.errorText = "Failed to fetch Pokémon data"
                }
            } else {
                print("No data received")
            }
        }.resume()
    }
}

struct PokemonSearch_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSearch()
    }
}
