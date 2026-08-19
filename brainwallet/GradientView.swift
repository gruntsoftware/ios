import UIKit

protocol SolidColorDrawable {
	func drawColor(color: UIColor, _ rect: CGRect)
}

extension UIView {
    func drawColor(color _: UIColor = BrainwalletUIColor.surface, _: CGRect) {
        let colorView = UIView()
        colorView.backgroundColor = BrainwalletUIColor.background
        addSubview(colorView)
        colorView.constrain(toSuperviewEdges: nil)
        sendSubviewToBack(colorView)
	}
}
