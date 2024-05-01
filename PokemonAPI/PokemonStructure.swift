//
//  PokemonStructure.swift
//  PokemonAPI
//
//  Created by SUN, JOHNNY on 5/1/24.
//

import Foundation

struct Ability: Codable {
    let name: String
    let url: String
}

struct AbilityDetail: Codable {
    let ability: Ability
    let is_hidden: Bool
    let slot: Int
}

struct Version: Codable {
    let name: String
    let url: String
}

struct GameIndex: Codable {
    let game_index: Int
    let version: Version
}

struct Item: Codable {
    let name: String
    let url: String
}

struct VersionDetail: Codable {
    let rarity: Int
    let version: Version
}

struct HeldItem: Codable {
    let item: Item
    let version_details: [VersionDetail]
}

struct MoveLearnMethod: Codable {
    let name: String
    let url: String
}

struct VersionGroup: Codable {
    let name: String
    let url: String
}

struct FormData: Codable {
    let name: String
    let url: String
}

struct VersionGroupDetail: Codable {
    let level_learned_at: Int
    let move_learn_method: MoveLearnMethod
    let version_group: VersionGroup
}
struct SpriteData: Codable{
    let front_default: String
}
struct TypeData: Codable{
    let name: String
}
struct Types: Codable{
    let type: TypeData
}

// Struct for representing a move
struct Move: Codable,Identifiable {
    let id = UUID()
    let move: MoveData
}

// Struct for representing move data
struct MoveData: Codable {
    let name: String
    let url: String
}

struct Stat: Codable, Identifiable {
    let id = UUID()
    let base_stat: Int
    let effort: Int
    let stat: StatData
}

// Struct for representing stat data
struct StatData: Codable {
    let name: String
    let url: String
}

struct ApiResponse: Codable {
    let forms: [FormData]
    let sprites: SpriteData
    let types: [Types]
    let name: String
    let moves: [Move]
    let stats: [Stat]

}
