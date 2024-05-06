//
//  PokemonCard.swift
//  PokemonAPI
//
//  Created by SUN, JOHNNY on 4/29/24.
//
 
import SwiftUI
 
struct PokemonCard: View {
    @Environment(\.dismiss) var dismiss
    let pokemon: ApiResponse
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    Text(pokemon.name.capitalized)
                        .font(.largeTitle)
                        .padding(.top, 60)
                    
                    
                    let typeNames = pokemon.types.map { $0.type.name.capitalized }.joined(separator: ", ")
                    Text("Type: \(typeNames)")
                    
                    AsyncImage(url: URL(string:pokemon.sprites.front_default)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Placeholder while loading
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
                    
                    VStack(alignment: .leading){
                        Text("Base Stats")
                        
                            .bold()
                            .padding([.bottom], 5)
                        ForEach(pokemon.stats ?? []){ stat in
                            Text(" \(stat.stat.name.capitalized) \(stat.base_stat)")
                            
                        }
                    }.padding([.bottom],10)
                    
                    Text("Weight: \(pokemon.weight)")
                    VStack{
                        Text("Avliable Moves")
                            .bold()
                            .padding([.top], 5)
                            .padding([.bottom], 5)
                        ForEach(pokemon.moves ?? []) { move in
                            Text(move.move.name.capitalized)
                        }
                    }
                    
                }
                
            }
     
            
            Button(action: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                dismiss()
            }){
                Text("Done")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(50)
                    .padding([.top],700)
            }
        }.background(Color.blue)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 5)
                    .padding(.bottom, -50)
            )
        

        
    }
        
}
 
//#Preview {
//    PokemonCard(pokemon: .pikachu)
//}
