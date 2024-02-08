//
//  Field.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//

struct Field {
    let width: Int
    let height: Int
    let loopX: Bool
    let loopY: Bool
    
    let allCellPositions: Set<Position>
    private(set) var minePositions: Set<Position>
    private(set) var openPositions: Set<Position>
    
    var closedCellPositions: Set<Position> {
        return allCellPositions.subtracting(openPositions)
    }
    
    init(width: Int, height: Int, loopX: Bool = false, loopY: Bool = false) {
        self.width = width
        self.height = height
        self.loopX = loopX
        self.loopY = loopY
        
        self.allCellPositions = Set(
            (0..<width).compactMap { x in
                (0..<height).compactMap { y in
                    Position(x: x, y: y)
                }
            }.flatMap { $0 }
        )
        
        self.minePositions = .init(minimumCapacity: width * height)
        self.openPositions = .init(minimumCapacity: width * height)
    }
    
    func isValid(x: Int, y: Int) -> Bool {
        return x >= 0 && x < width && y >= 0 && y < height
    }
    
    mutating func setMine(x: Int, y: Int) throws {
        guard isValid(x: x, y: y) else { throw Error.outOfRange }
        guard !hasMine(x: x, y: y) else { throw Error.alreadyHasMine }
        minePositions.insert(.init(x: x, y: y))
    }
    
    func hasMine(x: Int, y: Int) -> Bool {
        return minePositions.contains(.init(x: x, y: y))
    }
    
    func surroundingPositions(x: Int, y: Int) -> Set<Position> {
        guard isValid(x: x, y: y) else { return [] }
        var positions = Set<Position>(minimumCapacity: 8)
        for dy in -1...1 {
            for dx in -1...1 {
                do {
                    positions.insert(try position(x: x + dx, y: y + dy))
                } catch {}
            }
        }
        return positions
    }
    
    func numOfSurroundingMines(x: Int, y: Int) -> Int {
        return surroundingPositions(x: x, y: y)
            .filter { hasMine(x: $0.x, y: $0.y) }
            .count
    }
    
    mutating func open(x: Int, y: Int) throws {
        guard isValid(x: x, y: y) else { throw Error.outOfRange }
        guard !isOpen(x: x, y: y) else { throw Error.alreadyOpened }
        openPositions.insert(.init(x: x, y: y))
    }
    
    func isOpen(x: Int, y: Int) -> Bool {
        return openPositions.contains(.init(x: x, y: y))
    }
    
    mutating func reset() {
        minePositions.removeAll()
        openPositions.removeAll()
    }
}

extension Field {
    private func positionX(from x: Int) throws -> Int {
        if loopX {
            return (x + width) % width
        }
        if (0..<width).contains(x) {
            return x
        }
        throw Error.outOfRange
    }
    
    private func positionY(from y: Int) throws -> Int {
        if loopY {
            return (y + height) % height
        }
        if (0..<height).contains(y) {
            return y
        }
        throw Error.outOfRange
    }
    
    private func position(x: Int, y: Int) throws -> Position {
        return try Position(x: positionX(from: x), y: positionY(from: y))
    }
}

extension Field {
    enum Error: Swift.Error {
        case outOfRange
        case alreadyHasMine
        case alreadyOpened
    }
}
