//
//  JSONCodables.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/15/23.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int
    let title: String
    var cast: [String]?
}

struct CastResponse: Codable {
    let id: Int
    let cast: [Actor]
}

struct Actor: Codable {
    let name: String
}
