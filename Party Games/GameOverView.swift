//
//  GameOverView.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/17/23.
//

import SwiftUI
import Lottie

//Lottie Animations by Bruce: https://lottiefiles.com/bruce

struct GameOverView: View {
    
    @ObservedObject var gameModel: GameViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        LottieView(fileName: "sad")
                            .frame(width: geometry.size.width/3, height: geometry.size.width/3)
                            .rotationEffect(.degrees(180))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height/2)
                    .background(Color("Wrong"))
                    
                    ZStack {
                        LottieView(fileName: "cool")
                            .frame(width: geometry.size.width/3, height: geometry.size.width/3)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height/2)
                    .background(Color("Correct"))
                }
            }
            
            StartButtonView(label: "Play Again", emoji: "🔄")
                .onTapGesture {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    Task {
                        await gameModel.prepareNewGame()
                    }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    GameOverView(gameModel: GameViewModel())
}
