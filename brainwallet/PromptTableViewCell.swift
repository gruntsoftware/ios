import LocalAuthentication
import UIKit

class PromptTableViewCell: UITableViewCell {
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var bodyLabel: UILabel!
	@IBOutlet var tapButton: UIButton!

	var type: PromptType?
	var didClose: (() -> Void)?
	var didTap: (() -> Void)?

	@IBAction func didTapAction(_: Any) {
		didTap?()
	}

	@IBAction func closeAction(_: Any) {
		didClose?()
	}
}
