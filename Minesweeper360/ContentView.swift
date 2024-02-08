//
//  ContentView.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(Setting.self) var setting
    @Environment(Game.self) var game
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
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
            return "Minesweeper 360"
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 50) {
                Text(title)
                    .font(.largeTitle)
                    .padding()
                
                Toggle(immersiveSpaceIsShown ? "Retry" : "Play", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
                
                GroupBox {
                    @Bindable var setting = setting
                    VStack {
                        Text(String(format: "Scale: %.1f", setting.scale))
                        
                        Slider(value: $setting.scale, in: 0.1...2.0)
                    }
                    .padding()
                    
                    Button("Switch to " + (setting.immersionStyle is MixedImmersionStyle ? "Full" : "Mixed")) {
                        if setting.immersionStyle is MixedImmersionStyle {
                            setting.immersionStyle = .full
                        } else {
                            setting.immersionStyle = .mixed
                        }
                    }
                    .padding()
                    .disabled(!immersiveSpaceIsShown)
                }
                .frame(width: 400)
            }
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
