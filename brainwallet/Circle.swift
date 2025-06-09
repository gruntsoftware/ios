import UIKit

class Circle: UIView {
    private let circleForegroundColor: UIColor
    private let circleBorderColor: UIColor


    static let defaultSize: CGFloat = 64.0

    init(circleForegroundColor: UIColor,
         circleBorderColor: UIColor = BrainwalletUIColor.content) {
        self.circleForegroundColor = circleForegroundColor
        self.circleBorderColor = circleBorderColor
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw the border circle (outer circle)
        context.addEllipse(in: rect)
        context.setFillColor(circleBorderColor.cgColor)
        context.fillPath()
        
        // Draw the inner circle (background color)
        let borderWidth: CGFloat = 2.0
        let innerRect = rect.insetBy(dx: borderWidth, dy: borderWidth)
        context.addEllipse(in: innerRect)
        context.setFillColor(circleForegroundColor.cgColor)
        context.fillPath()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
