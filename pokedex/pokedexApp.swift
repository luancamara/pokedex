//
//  pokedexApp.swift
//  pokedex
//
//  Created by Luan Camara on 24/04/22.
//

import SwiftUI
import PokemonAPI

@main
struct pokedexApp: App {
    var body: some Scene {
        let pokemonAPI = PokemonAPI()
        WindowGroup {
            ContentView()
                .environmentObject(pokemonAPI)
        }
    }
}
