//
//  Game.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

import Observation

@Observable class Game {
    var field = Field(width: 0, height: 0)
    
    var numOfCells: Int {
        return field.width * field.height
    }
    
    var numOfMines: Int {
        return field.minePositions.count
    }
    
    var numOfOpenCells: Int {
        return field.openPositions.count
    }
    
    var isFailed: Bool {
        return field.minePositions.contains(where: field.openPositions.contains(_:))
    }
    
    var isCompleted: Bool {
        return numOfMines > 0 && !isFailed && numOfMines + numOfOpenCells == numOfCells
    }
    
    var isGameover: Bool {
        return isFailed || isCompleted
    }
    
    func openAllMines() {
        for p in field.minePositions {
            try? field.open(x: p.x, y: p.y)
        }
    }
    
    func openRecursively(x: Int, y: Int) throws {
        guard !field.hasMine(x: x, y: y) else { throw Error.failed }
        
        try field.open(x: x, y: y)
        
        if field.numOfSurroundingMines(x: x, y: y) == 0 {
            for p in field.surroundingPositions(x: x, y: y) {
                try? openRecursively(x: p.x, y: p.y)
            }
        }
    }
    
    func setRandomMines(num: Int) {
        var rest = num
        while rest > 0 {
            let x = Int.random(in: 0..<field.width)
            let y = Int.random(in: 0..<field.height)
            do {
                try field.setMine(x: x, y: y)
            } catch {
                continue
            }
            rest -= 1
        }
    }
}

extension Game {
    enum Error: Swift.Error {
        case failed
    }
}
