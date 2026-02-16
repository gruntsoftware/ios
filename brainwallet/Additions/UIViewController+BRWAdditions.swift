import UIKit

extension UIViewController {
	func addChildViewController(_ viewController: UIViewController, layout: () -> Void) {
		addChild(viewController)
		view.addSubview(viewController.view)
		layout()
		viewController.didMove(toParent: self)
	}

	func remove() {
		willMove(toParent: nil)
		view.removeFromSuperview()
		removeFromParent()
	}

	func addCloseNavigationItem(tintColor: UIColor? = nil) {

	}

	func hideCloseNavigationItem() {
		navigationItem.leftBarButtonItems = [UIBarButtonItem.negativePadding, UIBarButtonItem(customView: UIView())]
	}
}
