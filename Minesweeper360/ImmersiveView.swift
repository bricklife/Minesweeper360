//
//  ImmersiveView.swift
//  Minesweeper360
//
//  Created by Shinichiro Oba on 2024/02/08.
//


import SwiftUI
import RealityKit
import RealityKitContent

private let WIDTH = 50
private let HEIGHT = 10
private let R: Float = 3

struct ImmersiveView: View {
    @Environment(Setting.self) var setting
    @Environment(Game.self) var game
    
    var body: some View {
        RealityView { content in
            print("make")
            do {
                try await setup(content: &content)
            } catch {
                print(error)
            }
        } update: { content in
            print("update")
            update(content: &content)
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            print("tapped:", value.entity.name)
            
            guard !game.isCompleted else { return }
            guard !game.isFailed else { return }
            
            guard let p = Position(name: value.entity.name) else { return }
            do {
                try game.openRecursively(x: p.x, y: p.y)
            } catch Game.Error.failed {
                game.openAllMines()
            } catch {
                print(error)
            }
        })
    }
    
    @MainActor
    func setup(content: inout RealityViewContent) async throws {
        game.field = Field(width: WIDTH, height: HEIGHT, loopX: true)
        game.setRandomMines(num: game.numOfCells / 10)
        
        let cube = try await Entity(named: "Cube", in: realityKitContentBundle)
        let mine = try await Entity(named: "Mine", in: realityKitContentBundle)
        var numbers: [Int: Entity] = [:]
        for n in 1...8 {
            let name = n.description
            numbers[n] = try await Entity(named: name, in: realityKitContentBundle)
        }
        
        let root = Entity()
        let transformer = FieldTransformer(width: game.field.width, r: R)
        
        for p in game.field.allCellPositions {
            let transform = transformer.transform(x: p.x, y: p.y)
            
            let e = Entity()
            e.addChild(cube.clone(recursive: true))
            e.components.set(HoverEffectComponent())
            e.components.set(InputTargetComponent())
            e.components.set(CollisionComponent(shapes: [.generateBox(size: .one)]))
            e.transform = transform
            e.name = p.name
            root.addChild(e)
            
            if game.field.hasMine(x: p.x, y: p.y) {
                let m = mine.clone(recursive: true)
                m.transform = transform
                root.addChild(m)
            } else {
                let num = game.field.numOfSurroundingMines(x: p.x, y: p.y)
                if let n = numbers[num]?.clone(recursive: true) {
                    n.transform = transform
                    root.addChild(n)
                }
            }
        }
        
        content.add(root)
    }
    
    func update(content: inout RealityViewContent) {
        let scale = setting.scale
        content.entities.first?.transform = Transform(scale: .init(x: scale, y: scale, z: scale))
        
        for p in game.field.openPositions {
            content.entities.first?.findEntity(named: p.name)?.removeFromParent()
        }
        if game.isGameover {
            print("gameover")
            for p in game.field.closedCellPositions {
                guard let cell = content.entities.first?.findEntity(named: p.name) else { continue }
                if game.field.hasMine(x: p.x, y: p.y) {
                    cell.removeFromParent()
                } else {
                    cell.components.remove(HoverEffectComponent.self)
                }
            }
        }
    }
}

extension ImmersiveView {
    struct FieldTransformer {
        let r: Float
        let size: Float
        let angleUnit: Float
        
        init(width: Int, r: Float) {
            self.r = r
            self.size = Float.pi * r * 2 / Float(width)
            self.angleUnit = Float.pi * 2 / Float(width)
        }
        
        func transform(x: Int, y: Int) -> Transform {
            return Transform(
                scale: .init(x: size * 0.98, y: size * 0.98, z: size * 0.98),
                rotation: .init(angle: angleUnit * Float(-x) - (Float.pi / 2) , axis: .init(x: 0, y: 1, z: 0)),
                translation: .init(x: cos(angleUnit * Float(x)) * (r + size / 2), y: Float(y) * size, z: sin(angleUnit * Float(x)) * (r + size / 2))
            )
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
