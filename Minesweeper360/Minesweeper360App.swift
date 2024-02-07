//
//  Minesweeper360App.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

import SwiftUI

@main
struct MineSweeper360App: App {
    
    @State private var immersionStyle: ImmersionStyle = .mixed
    @State private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView(immersionStyle: $immersionStyle)
                .environment(game)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(game)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .full)
    }
}
