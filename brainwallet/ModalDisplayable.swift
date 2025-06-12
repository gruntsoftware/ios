import UIKit

protocol ModalDisplayable {
	var modalTitle: String { get }
}

protocol ModalPresentable {
	var parentView: UIView? { get set }
}
