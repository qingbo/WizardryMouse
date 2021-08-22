//
//  StatusBarView.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import SwiftUI
import CoreGraphics


struct StatusItemView: View {
    @EnvironmentObject var batteryStatus: BatteryLevelReader
    let threshold = 0.2
    var height: CGFloat

    var body: some View {
        ZStack {
            mouseBackground()

            if batteryStatus.minBatteryLevel != nil {
                batteryLevel()
            } else {
                Text("?")
            }

            dotAsApple()
        }
    }

    private func mouseBackground() -> some View {
        MagicMouse()
            .fill(
                batteryStatus.minBatteryLevel == nil || batteryStatus.minBatteryLevel! > threshold ?
                Color(.sRGB, white: 0.3, opacity: 0.4) : // Gray mouse when unkown or above threshold
                Color(.sRGB, red: 255, green: 0, blue: 0, opacity: 0.4) // Red mouse when low battery level
            )
            .frame(
                width: height * 2,
                height: height,
                alignment: .center
            )
    }

    private func batteryLevel() -> some View {
        HStack {
            Rectangle()
                .fill(batteryStatus.minBatteryLevel! > threshold ? Color.black : Color.red)
                .frame(
                    // Width is calculated based on battery level
                    width: height * 1.9 * CGFloat(batteryStatus.minBatteryLevel!),
                    height: height,
                    alignment: .leading
                )
                .offset(x: height * 0.05)
        }
        .frame(
            width: height * 2,
            height: height,
            alignment: .leading
        )
        .mask(
            MagicMouse()
                .frame(
                    width: height * 2,
                    height: height,
                    alignment: .center
                )
        )
    }

    private func dotAsApple() -> some View {
        // Apple logo is not permitted to be used here, and at this scale a dot is enough.
        Circle()
            .fill(Color(.sRGB, white: 0.7, opacity: 1.0))
            .frame(
                width: CGFloat(4),
                height: CGFloat(4),
                alignment: .center
            )
            .offset(x: -height / 2)
    }
}

struct MagicMouse: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(
            to: CGPoint(
                x: rect.minX + rect.width * MousePathParameters.start.x,
                y: rect.minY + rect.height * MousePathParameters.start.y
            )
        )
        MousePathParameters.segments.forEach { segment in
            path.addQuadCurve(
                to: CGPoint(
                    x: rect.minX + rect.width * segment.curve.x,
                    y: rect.minY + rect.height * segment.curve.y
                ),
                control: CGPoint(
                    x: rect.minX + rect.width * segment.control.x,
                    y: rect.minY + rect.height * segment.control.y
                )
            )
        }
        return path
    }
}

struct MousePathParameters {
    struct Segment {
        let curve: CGPoint
        let control: CGPoint
    }

    static let hMargin: CGFloat = 0.05
    static let vMargin: CGFloat = 0.05

    static let start = CGPoint(
        x: hMargin * 1.1,
        y: (0.5 - vMargin) * 0.5 + vMargin
    )

    static let segments = [
        Segment(
            curve: CGPoint(
                x: (0.5 - hMargin) * 0.4 + hMargin,
                y: vMargin * 1.1
            ),
            control: CGPoint(x: hMargin * 1.7, y: vMargin * 1.7)
        ),
        Segment(
            curve: CGPoint(
                x: 1 - ((0.5 - hMargin) * 0.4 + hMargin),
                y: vMargin * 1.1
            ),
            control: CGPoint(x: 0.5, y: vMargin * 0.5)
        ),
        Segment(
            curve: CGPoint(
                x: 1 - hMargin * 1.1,
                y: (0.5 - vMargin) * 0.5 + vMargin
            ),
            control: CGPoint(x: 1 - hMargin * 1.7, y: vMargin * 1.7)
        ),
        Segment(
            curve: CGPoint(
                x: 1 - hMargin * 1.1,
                y: 1 - ((0.5 - vMargin) * 0.5 + vMargin)
            ),
            control: CGPoint(x: 1 - hMargin * 0.6, y: 0.5)
        ),
        Segment(
            curve: CGPoint(
                x: 1 - ((0.5 - hMargin) * 0.4 + hMargin),
                y: 1 - vMargin * 1.1
            ),
            control: CGPoint(x: 1 - hMargin * 1.7, y: 1 - vMargin * 1.7)
        ),
        Segment(
            curve: CGPoint(
                x: (0.5 - hMargin) * 0.4 + hMargin,
                y: 1 - vMargin * 1.1
            ),
            control: CGPoint(x: 0.5, y: 1 - vMargin * 0.5)
        ),
        Segment(
            curve: CGPoint(
                x: hMargin * 1.1,
                y: 1 - ((0.5 - vMargin) * 0.5 + vMargin)
            ),
            control: CGPoint(x: hMargin * 1.7, y: 1 - vMargin * 1.7)
        ),
        Segment(
            curve: start,
            control: CGPoint(x: hMargin * 0.6, y: 0.5)
        ),
    ]
}
