//
//  GameView.swift
//  Party Games
//
//  Created by Oliver Carlock on 8/30/23.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var gameModel = GameViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                MovieBlockView(gameModel: gameModel,
                               flip: true)
                
                GeometryReader { geometry in
                    // P1 View
                    PlayerView(gameModel: gameModel,
                               isGameStarted: gameModel.isGameStarted,
                               text: gameModel.actors[gameModel.currentActorIndex],
                               fraction: gameModel.playerOneCurrentFraction,
                               backgroundColor: Color("P1Color"),
                               flip: true,
                               geometry: geometry)
                    
                    // P2 View
                    PlayerView(gameModel: gameModel,
                               isGameStarted: gameModel.isGameStarted,
                               text: gameModel.actors[gameModel.currentActorIndex],
                               fraction: gameModel.playerTwoCurrentFraction,
                               backgroundColor: Color("P2Color"),
                               flip: false,
                               geometry: geometry)
                }
                
                MovieBlockView(gameModel: gameModel,
                               flip: false)
                
            }
            
            TouchView(gameModel: gameModel)
                .zIndex(6)
                .allowsHitTesting(gameModel.isGameStarted && !gameModel.isHolding && !gameModel.isGameOver)
            
            ProgressView()
                .frame(width: 30, height: 30)
                .background(.black)
                .cornerRadius(15)
                .scaleEffect(CGSize(width: gameModel.isGameLoaded ? 0 : 2, height: gameModel.isGameLoaded ? 0 : 2))
            
            StartButtonView(label: "Start Game",
                            emoji: "⚔️")
                .scaleEffect(CGSize(width: gameModel.isGameStarted || !gameModel.isGameLoaded ? 0 : 1, height: gameModel.isGameStarted || !gameModel.isGameLoaded ? 0 : 1))
                .onTapGesture {
                    let impactFeedback = UIImpactFeedbackGenerator(style:   .light)
                    impactFeedback.impactOccurred()
                    gameModel.startGame()
                }
                .zIndex(9)
            
            GeometryReader { geometry in
                GameOverView(gameModel: gameModel)
                    .rotationEffect(.degrees(gameModel.playerOneIsActive ? (gameModel.playerOnePoints < gameModel.playerTwoPoints ? 180 : 0) : (gameModel.playerOnePoints > gameModel.playerTwoPoints ? 180 : 0)))
                        .offset(y: gameModel.isGameOver ? 0 : -geometry.size.height)
                    .rotationEffect(.degrees(gameModel.playerOneIsActive ? 180 : 0))
            }
            .zIndex(10)
            
        }
        .onAppear {
            gameModel.loadGame()
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .alert(isPresented: $gameModel.showError, content: {
            return Alert(
                title: Text("Error Setting Up Game"),
                message: Text(gameModel.fetchError?.description ?? "Unknown Error Occurred."),
                dismissButton: .default(Text("Try Again")) {
                    Task {
                        try await Task.sleep(nanoseconds: 250000000)
                        await gameModel.prepareNewGame()
                    }
                }
            )
        })
    }
    
}

#Preview {
    GameView()
}
