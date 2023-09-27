//
//  MovieBlockView.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/18/23.
//

import SwiftUI

struct MovieBlockView: View {
    @ObservedObject var gameModel: GameViewModel
    
    let flip: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 100, height: 10))
                .foregroundColor(.black)
                .frame(height: 150)
                .offset(y: flip ? 10 : -10)
            
            VStack {
                Text(gameModel.movies.count > gameModel.currentMovieIndex ? gameModel.movies[gameModel.currentMovieIndex].title : "")
                    .opacity(gameModel.isGameStarted ? 1 : 0)
                    .textCase(.uppercase)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 25)
                    .padding(.horizontal, 60)
                Spacer()
            }
            .rotationEffect(.degrees(flip ? 180 : 0))
        }
        .frame(height: 125)
        .zIndex(4)
    }
}

//#Preview {
//    MovieBlockView(gameModel: GameViewModel(), flip: true)
//}
