//
//  Position.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

struct Position: Hashable {
    let x: Int
    let y: Int
}

extension Position {
    var name: String {
        "\(x)-\(y)"
    }
    
    init?(name: String) {
        if let match = name.firstMatch(of: /^(\d+)-(\d+)$/) {
            self = .init(x: Int(match.1)!, y: Int(match.2)!)
        } else {
            return nil
        }
    }
}
