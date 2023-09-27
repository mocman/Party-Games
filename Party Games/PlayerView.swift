//
//  PlayerView.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/18/23.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var gameModel: GameViewModel
    
    let isGameStarted: Bool
    let text: String
    let fraction: CGFloat
    let backgroundColor: Color
    let flip: Bool
    let geometry: GeometryProxy
    
    var body: some View {
        Text(text)
            .opacity(isGameStarted ? 1 : 0)
            .font(.largeTitle)
            .fontWeight(.thin)
            .foregroundColor(.white)
            .rotationEffect(.degrees(flip ? 180 : 0))
            .frame(width: geometry.size.width, height: geometry.size.height * fraction)
            .background(gameModel.isCorrect != nil && (flip ? gameModel.playerOneIsActive : !gameModel.playerOneIsActive)
                        ? (gameModel.isCorrect! ? Color("Correct") : Color("Wrong"))
                        : backgroundColor
            )
            .position(
                x: geometry.size.width * 0.5,
                y: flip
                ? geometry.size.height * fraction * 0.5
                : geometry.size.height - (geometry.size.height * fraction * 0.5)
            )
            .zIndex(gameModel.playerOneIsActive ? 1 : 0)
    }
}

//#Preview {
//    PlayerView()
//}
