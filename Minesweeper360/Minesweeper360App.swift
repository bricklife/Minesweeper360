//
//  Minesweeper360App.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

import SwiftUI

@Observable class Setting {
    var immersionStyle: ImmersionStyle = .mixed
    var scale: Float = 1.0
}

@main
struct MineSweeper360App: App {
    
    @State private var setting = Setting()
    @State private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(setting)
                .environment(game)
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(setting)
                .environment(game)
        }
        .immersionStyle(selection: $setting.immersionStyle, in: .mixed, .full)
    }
}
