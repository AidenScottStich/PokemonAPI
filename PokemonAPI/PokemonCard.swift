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
        
        VStack{
            Text("Pokemon Card").font(.largeTitle).padding(50)
            
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
            Text(pokemon.name)
            
            let typeNames = pokemon.types.map { $0.type.name }.joined(separator: ", ")
            Text("Type: \(typeNames)")
     
     
            
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
            }
        }
        .background(Color.blue)
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 5)

        
    }
        
}
 
//#Preview {
//    PokemonCard(pokemon: .pikachu)
//}