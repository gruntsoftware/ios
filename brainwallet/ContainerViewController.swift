import Foundation
import UIKit

class ContainerViewController: UIViewController {
	override func viewDidLoad() {}
}

extension ContainerViewController: ModalDisplayable {
	var modalTitle: String {
		return ""
	}
}
