//
//  ContentView.swift
//  PokemonAPI
//
//  Created by STICH, AIDEN SCOTT on 4/24/24.
//
 
import SwiftUI
 
struct ContentView: View {
    var body: some View {
        ZStack {
            TabView {
                ListView()
                    .tabItem {
                        Label("Home", systemImage: "person")
                    }
                PokemonSearch()
                    .tabItem {
                        Label("Pokemon Search", systemImage: "magnifyingglass")
                    }
                    
            }
            .tint(.black)
                    .onAppear(perform: {
                        //2
                        UITabBar.appearance().unselectedItemTintColor = .systemBlue
                        //4
                        UITabBar.appearance().backgroundColor = .white.withAlphaComponent(0.9)
                    })
        }
    }
}

 
#Preview {
    ContentView()
}
