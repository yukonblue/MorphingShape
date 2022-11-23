//
//  MorphingCircleView.swift
//  MorphingShape
//
//  Created by yukonblue on 07/23/2022.
//

/// https://alexdremov.me/swiftui-advanced-animation/

import Foundation
import SwiftUI

public struct MorphingCircleView: View & Identifiable & Hashable {
    public static func == (lhs: MorphingCircleView, rhs: MorphingCircleView) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let defaultFill = AnyShapeStyle(LinearGradient(colors: [.orange, .pink],
                                                          startPoint: .topLeading,
                                                          endPoint: .bottomTrailing))
    public let id = UUID()
    @State var morph: AnimatableVector = AnimatableVector.zero
    @State var timer: Timer?

    func morphCreator() -> AnimatableVector {
        let range = Float(-morphingRange)...Float(morphingRange)
        var morphing = Array.init(repeating: Float.zero, count: self.points)
        for i in 0..<morphing.count where Int.random(in: 0...1) == 0 {
            morphing[i] = Float.random(in: range)
        }
        return AnimatableVector(values: morphing)
    }

    func update() {
        morph = morphCreator()
    }

    let duration: Double
    let points: Int
    let secting: Double
    let size: CGFloat
    let outerSize: CGFloat
    var fill: AnyShapeStyle
    let morphingRange: CGFloat

    var radius: CGFloat {
        outerSize / 2
    }

    public var body: some View {
        MorphingCircleShape(morph)
            .fill(self.fill)
            .frame(width: size, height: size, alignment: .center)
            .animation(Animation.easeInOut(duration: Double(duration + 1.0)), value: morph)
            .onAppear {
                DispatchQueue.main.async {
                    update()
                    timer = Timer.scheduledTimer(withTimeInterval: duration / secting, repeats: true) { timer in
                        update()
                    }
                }
            }.onDisappear {
                timer?.invalidate()
            }
            .frame(width: outerSize, height: outerSize, alignment: .center)
            .animation(nil, value: morph)
    }

    public init(_ size: CGFloat = 300, morphingRange: CGFloat = 30, color: Color = .red, points: Int = 4, duration: Double = 5.0, secting: Double = 2) {
        self.init(size, morphingRange: morphingRange, fill: AnyShapeStyle(color), points: points, duration: duration, secting: secting)
    }

    public init(_ size: CGFloat = 300, morphingRange: CGFloat = 30, fill: AnyShapeStyle, points: Int = 4, duration: Double = 5.0, secting: Double = 2) {
        self.points = points
        self.fill = fill
        self.morphingRange = morphingRange
        self.duration = duration
        self.secting = secting
        self.size = morphingRange * 2 < size ? size - morphingRange * 2 : 5
        self.outerSize = size
        morph = AnimatableVector(values: [])
        update()
    }

    public static let `default` = MorphingCircleView(fill: Self.defaultFill)

    func color(_ newColor: Color) -> MorphingCircleView {
        var morphNew = self
        morphNew.fill = AnyShapeStyle(newColor)
        return morphNew
    }
}
