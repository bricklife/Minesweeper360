//
//  ContentView.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    @Binding var immersionStyle: ImmersionStyle
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(Game.self) var game
    
    var title: String {
        if immersiveSpaceIsShown {
            if game.isFailed {
                return "Lose..."
            } else if game.isCompleted {
                return "Win!"
            } else {
                return "Playing..."
            }
        } else {
            return "Minesweeper360"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(title)
                    .font(.largeTitle)
                
                Toggle(immersiveSpaceIsShown ? "Retry" : "Play", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
                    .padding()
                
                Button("Switch to " + (immersionStyle is MixedImmersionStyle ? "Full" : "Mixed")) {
                    if immersionStyle is MixedImmersionStyle {
                        immersionStyle = .full
                    } else {
                        immersionStyle = .mixed
                    }
                }
                .disabled(!immersiveSpaceIsShown)
            }
            .padding(100)
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}
