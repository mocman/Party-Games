//
//  StartButtonView.swift
//  Party Games
//
//  Created by Oliver Carlock on 9/18/23.
//

import SwiftUI

struct StartButtonView: View {
    
    @State var label: String = ""
    @State var emoji: String = ""
    
    @State private var startButtonScale: Double = 1
    @State private var startButtonRotation: Double = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text(label)
                    .rotationEffect(.degrees(180))
                Spacer()
                Text(label)
            }
            VStack {
                Text(label)
                    .rotationEffect(.degrees(180))
                Spacer()
                Text(label)
            }
            .rotationEffect(.degrees(90))
            Text(emoji)
                .font(.largeTitle)
        }
        .font(.subheadline)
        .fontWeight(.bold)
        .textCase(.uppercase)
        .foregroundColor(.white)
        .padding()
        .frame(width: 180, height: 180)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 60))
        .scaleEffect(CGSize(width: startButtonScale, height: startButtonScale))
        .rotationEffect(.degrees(startButtonRotation))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    startButtonRotation = 359
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    startButtonScale = 0.9
                }
            })
        }
    }
}

#Preview {
    StartButtonView()
}
