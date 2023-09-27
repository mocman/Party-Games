//
//  Errors.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/18/23.
//

import Foundation

enum FetchError: Error {
    case connectionError
    case apiKeyError
    
    var description: String {
        switch self {
        case .connectionError:
            return "Could not recieve game data."
        case .apiKeyError:
            return "Error accessing API Key."
        }
    }
}
