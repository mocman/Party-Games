//
//  TouchView.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/18/23.
//

import SwiftUI

struct TouchView: View {
    @ObservedObject var gameModel: GameViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // P1 View
                Color.red.opacity(0.001)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.25)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                gameModel.handleDragChanged(isPlayerOne: true)
                            }
                            .onEnded { _ in
                                gameModel.handleDragEnded()
                            }
                    )
                
                // P2 View
                Color.blue.opacity(0.001)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height - (geometry.size.height * 0.25))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                gameModel.handleDragChanged(isPlayerOne: false)
                            }
                            .onEnded { _ in
                                gameModel.handleDragEnded()
                            }
                    )
            }
        }
    }
}

//#Preview {
//    TouchView(gameModel: GameViewModel())
//}
