import Foundation
import UIKit

class FeeSelector: UIView {
	init(store: Store) {
		self.store = store
		super.init(frame: .zero)
		setupViews()
	}

	var didUpdateFee: ((FeeType) -> Void)?

	func removeIntrinsicSize() {
		guard let bottomConstraint = bottomConstraint else { return }
		NSLayoutConstraint.deactivate([bottomConstraint])
	}

	func addIntrinsicSize() {
		guard let bottomConstraint = bottomConstraint else { return }
		NSLayoutConstraint.activate([bottomConstraint])
	}

	//: ::
	private let store: Store
	private let header = UILabel(font: .barlowMedium(size: 16.0), color: BrainwalletUIColor.content)
	private let subheader = UILabel(font: .barlowRegular(size: 14.0), color: BrainwalletUIColor.content)
    private let feeMessageLabel = UILabel.wrapping(font: .barlowSemiBold(size: 14.0), color: BrainwalletUIColor.content)
	private let control = UISegmentedControl(items: ["Regular" , "Economy" , "Luxury" ])
	private var bottomConstraint: NSLayoutConstraint?

	private func setupViews() {
		addSubview(control)
		addSubview(header)
		addSubview(subheader)
		addSubview(feeMessageLabel)

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: BrainwalletUIColor.surface]
        let normalTitleTextAttributes = [NSAttributedString.Key.foregroundColor: BrainwalletUIColor.gray]

        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(normalTitleTextAttributes, for: .normal)

        control.tintColor = BrainwalletUIColor.info
        control.backgroundColor = BrainwalletUIColor.border
        control.selectedSegmentTintColor = BrainwalletUIColor.info

		header.constrain([
			header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
			header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
			header.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[1])
		])
		subheader.constrain([
			subheader.leadingAnchor.constraint(equalTo: header.leadingAnchor),
			subheader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
			subheader.topAnchor.constraint(equalTo: header.bottomAnchor)
		])

		bottomConstraint = feeMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[1])
		feeMessageLabel.constrain([
			feeMessageLabel.leadingAnchor.constraint(equalTo: subheader.leadingAnchor),
			feeMessageLabel.topAnchor.constraint(equalTo: control.bottomAnchor, constant: 4.0),
			feeMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2])
		])
		header.text =  String(localized: "Processing Speed", bundle: .main)
		subheader.text = String(localized: "Estimated Delivery: 2.5 - 5+ minutes", bundle: .main)
		control.constrain([
			control.leadingAnchor.constraint(equalTo: feeMessageLabel.leadingAnchor),
			control.topAnchor.constraint(equalTo: subheader.bottomAnchor, constant: 4.0),
			control.widthAnchor.constraint(equalTo: widthAnchor, constant: -C.padding[4])
		])

		control.valueChanged = strongify(self) { myself in
			switch myself.control.selectedSegmentIndex {
			case 0:
				myself.didUpdateFee?(.regular)
				myself.subheader.text = String(localized: "Estimated Delivery: 2.5 - 5+ minutes", bundle: .main)
				myself.feeMessageLabel.text = ""
			case 1:
				myself.didUpdateFee?(.economy)
				myself.subheader.text = String(localized: "Estimated Delivery: ~10 minutes", bundle: .main)
				myself.feeMessageLabel.text = String(localized: "This option is not recommended for time-sensitive transactions.", bundle: .main)
                myself.feeMessageLabel.textColor = BrainwalletUIColor.error
			case 2:
				myself.didUpdateFee?(.luxury)
				myself.subheader.text = String(localized: "Delivery: 2.5 - 5+  minutes", bundle: .main)
				myself.feeMessageLabel.text = String(localized: "This option virtually guarantees acceptance of your transaction while you pay a premium.", bundle: .main)
                myself.feeMessageLabel.textColor = BrainwalletUIColor.content
			default:
				myself.didUpdateFee?(.regular)
				myself.subheader.text = String(localized: "Estimated Delivery: 2.5 - 5+ minutes", bundle: .main)
				myself.feeMessageLabel.text = ""
				BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["FEE_MANAGER": "DID_USE_DEFAULT"])
			}
		}

		control.selectedSegmentIndex = 0
		clipsToBounds = true
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
