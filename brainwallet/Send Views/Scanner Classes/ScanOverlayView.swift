//
//  ScanOverlayView.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import UIKit

class ScanOverlayView: UIView {
    private let squareSize: CGFloat = 250
    private let cornerLength: CGFloat = 30
    private let cornerWidth: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Draw semi-transparent overlay
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)

        // Calculate center square position
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        let squareRect = CGRect(
            x: centerX - squareSize / 2,
            y: centerY - squareSize / 2,
            width: squareSize,
            height: squareSize
        )

        // Clear the center square
        context.clear(squareRect)

        // Draw corner brackets
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(cornerWidth)
        context.setLineCap(.round)

        // Top-left corner
        context.move(to: CGPoint(x: squareRect.minX + cornerLength, y: squareRect.minY))
        context.addLine(to: CGPoint(x: squareRect.minX, y: squareRect.minY))
        context.addLine(to: CGPoint(x: squareRect.minX, y: squareRect.minY + cornerLength))

        // Top-right corner
        context.move(to: CGPoint(x: squareRect.maxX - cornerLength, y: squareRect.minY))
        context.addLine(to: CGPoint(x: squareRect.maxX, y: squareRect.minY))
        context.addLine(to: CGPoint(x: squareRect.maxX, y: squareRect.minY + cornerLength))

        // Bottom-left corner
        context.move(to: CGPoint(x: squareRect.minX, y: squareRect.maxY - cornerLength))
        context.addLine(to: CGPoint(x: squareRect.minX, y: squareRect.maxY))
        context.addLine(to: CGPoint(x: squareRect.minX + cornerLength, y: squareRect.maxY))

        // Bottom-right corner
        context.move(to: CGPoint(x: squareRect.maxX, y: squareRect.maxY - cornerLength))
        context.addLine(to: CGPoint(x: squareRect.maxX, y: squareRect.maxY))
        context.addLine(to: CGPoint(x: squareRect.maxX - cornerLength, y: squareRect.maxY))

        context.strokePath()

        let instructionText = String(localized: "Align within frame. Tap to scan")
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let textSize = instructionText.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: centerX - textSize.width / 2,
            y: squareRect.maxY + 20,
            width: textSize.width,
            height: textSize.height
        )
        instructionText.draw(in: textRect, withAttributes: textAttributes)
    }
}
