//
//  ContentView.swift
//  pokedex
//
//  Created by Luan Camara on 24/04/22.
//

import SwiftUI
import PokemonAPI

struct ContentView: View {
    @EnvironmentObject var pokemonAPI: PokemonAPI
    var body: some View {
        PaginatedResultsView(pokemonAPI: _pokemonAPI, pageIndex: .max)
    }
}

struct PaginatedResultsView: View {
    @EnvironmentObject var pokemonAPI: PokemonAPI
    @State var error: Error?
    @State var pagedObject: PKMPagedObject<PKMPokemon>?
    @State var pageIndex = 0


    var body: some View {
        mainContent
            .task {
                await fetchPokemon()
            }
    }


    var mainContent: some View {
        VStack {
            if let error = error {
                Text("An error occurred: \(error.localizedDescription)")
            } else if
                let pagedObject = pagedObject,
                let pokemonResults = pagedObject.results as? [PKMNamedAPIResource]
            {
                ScrollView {
                    ForEach(pokemonResults, id: \.url) { pokemon in
                        PokemonDisplay(
                            url: pokemon.url,
                            name: pokemon.name!
                        )
                    }
                }
            }
        }
    }

    // MARK: - Data

    func fetchPokemon(
        paginationState: PaginationState<PKMPokemon> = .initial(pageLimit: .max)) async
    {
        do {
            pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(paginationState: paginationState)
            pageIndex = pagedObject?.currentPage ?? 0
        }
        catch {
            self.error = error
        }
    }
}

struct PokemonImage: View {
    @State var url: String?
    var body: some View {
        AsyncImage(url: getPokemonImageURL()) { image in
            image
                .shadow(color: .black, radius: 1, x: 1, y: 1)
                .frame(width: 90, height: 90)
        } placeholder: {
            RoundedRectangle(cornerRadius: 40)
                .foregroundColor(Color.black.opacity(0.2))
                .frame(width: 90, height: 90)
        }

    }

    func getPokemonImageURL() -> URL? {
        guard
            let urlString = self.url,
            let url = URL(string: urlString) else {
            return nil
        }

        let result = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(url.lastPathComponent).png"

        return URL(string: result)
    }
}

struct PokemonDisplay: View {
    @State var url: String?
    @State var name: String
    var body: some View {
        HStack {
            PokemonImage(url: url)
                .padding(.leading, 30)
            Spacer()
            Text("\(name.first!.uppercased() + name.dropFirst())")
                .bold()
                .font(.system(size: 25))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 90)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

struct PokemonDisplay_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDisplay(url: "https://pokeapi.co/api/v2/pokemon/1/", name: "bulbasaur")
            .previewLayout(.sizeThatFits)
    }
}

extension PokemonAPI: ObservableObject { }
