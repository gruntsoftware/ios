import UIKit

enum PinPadColorStyle {
	case whitePinPadStyle
	case clearPinPadStyle
}

enum KeyboardType {
	case decimalPad
	case pinPad
}

let deleteKeyIdentifier = "del"
let kDecimalPadItemHeight: CGFloat = 48.0
let kPinPadItemHeight: CGFloat = 54.0

class PinPadViewController: UICollectionViewController {
	let currencyDecimalSeparator = NumberFormatter().currencyDecimalSeparator ?? "."
	var isAppendingDisabled = false
	var ouputDidUpdate: ((String) -> Void)?
	var didUpdateFrameWidth: ((CGRect) -> Void)?

	var height: CGFloat {
		switch keyboardType {
		case .decimalPad:
			return kDecimalPadItemHeight * 4.0 // for four rows tall
		case .pinPad:
			return kPinPadItemHeight * 4.0 // for four rows tall
		}
	}

	var currentOutput = ""

	func clear() {
		isAppendingDisabled = false
		currentOutput = ""
	}

	func removeLast() {
		if !currentOutput.utf8.isEmpty {
			currentOutput = String(currentOutput[..<currentOutput.index(currentOutput.startIndex, offsetBy: currentOutput.utf8.count - 1)])
		}
	}

	init(style: PinPadColorStyle, keyboardType: KeyboardType, maxDigits: Int) {
		self.style = style
		self.keyboardType = keyboardType
		self.maxDigits = maxDigits
		let layout = UICollectionViewFlowLayout()
		let screenWidth = UIScreen.main.safeWidth

		layout.minimumLineSpacing = 1.0
		layout.minimumInteritemSpacing = 1.0
		layout.sectionInset = .zero

		// This value caused havoc (=1.0) on the iPad UI as the margins were previously too small. And items would be truncated
		let itemWidthWithMargin = screenWidth / 3.0 - 2.0

		switch keyboardType {
		case .decimalPad:
			items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", currencyDecimalSeparator, "0", deleteKeyIdentifier]
			layout.itemSize = CGSize(width: itemWidthWithMargin, height: kDecimalPadItemHeight - 1.0)
		case .pinPad:
			items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", deleteKeyIdentifier]
			layout.itemSize = CGSize(width: itemWidthWithMargin, height: kPinPadItemHeight - 0.5)
		}

		super.init(collectionViewLayout: layout)
	}

	private let cellIdentifier = "CellIdentifier"
	private let style: PinPadColorStyle
	private let keyboardType: KeyboardType
	private let items: [String]
	private let maxDigits: Int

	override func viewDidLoad() {
		switch style {
        case .whitePinPadStyle:
			switch keyboardType {
			case .decimalPad:
				collectionView?.backgroundColor = .clear
				collectionView?.register(WhiteDecimalPad.self, forCellWithReuseIdentifier: cellIdentifier)
			case .pinPad:
				collectionView?.backgroundColor = .clear
				collectionView?.register(WhiteNumberPad.self, forCellWithReuseIdentifier: cellIdentifier)
			}
        case .clearPinPadStyle:
			switch keyboardType {
			case .decimalPad:
				collectionView?.backgroundColor = .clear
				collectionView?.register(ClearDecimalPad.self, forCellWithReuseIdentifier: cellIdentifier)
			case .pinPad:
				collectionView?.backgroundColor = .clear
				collectionView?.register(ClearNumberPad.self, forCellWithReuseIdentifier: cellIdentifier)
			}
		}
		collectionView?.delegate = self
		collectionView?.dataSource = self

		// Even though this view will never scroll, this stops a gesture recognizer
		// from listening for scroll events
		// This prevents a delay in cells highlighting right when they are tapped
		collectionView?.isScrollEnabled = false
	}

	// MARK: - UICollectionViewDataSource

	override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
		return items.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
		guard let pinPadCell = item as? GenericPinPadCell else { return item }
		pinPadCell.text = items[indexPath.item]

		// produces a frame for lining up other subviews
		if indexPath.item == 0 {
			didUpdateFrameWidth?(collectionView.convert(pinPadCell.frame, to: view))
		}
		return pinPadCell
	}

	// MARK: - UICollectionViewDelegate

	override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = items[indexPath.row]
		if item == "del" {
			if !currentOutput.isEmpty {
				if currentOutput == ("0" + currencyDecimalSeparator) {
					currentOutput = ""
				} else {
					currentOutput.remove(at: currentOutput.index(before: currentOutput.endIndex))
				}
			}
		} else {
			if shouldAppendChar(char: item), !isAppendingDisabled {
				currentOutput = currentOutput + item
			}
		}
		ouputDidUpdate?(currentOutput)
	}

	func shouldAppendChar(char: String) -> Bool {
		let decimalLocation = currentOutput.range(of: currencyDecimalSeparator)?.lowerBound

		// Don't allow more that maxDigits decimal points
		if let location = decimalLocation {
			let locationValue = currentOutput.distance(from: currentOutput.endIndex, to: location)
			if locationValue < -maxDigits {
				return false
			}
		}

		// Don't allow more than 2 decimal separators
		if currentOutput.contains("\(currencyDecimalSeparator)"), char == currencyDecimalSeparator {
			return false
		}

		if keyboardType == .decimalPad {
			if currentOutput == "0" {
				// Append . to 0
				if char == currencyDecimalSeparator {
					return true

					// Dont append 0 to 0
				} else if char == "0" {
					return false

					// Replace 0 with any other digit
				} else {
					currentOutput = char
					return false
				}
			}
		}

		if char == currencyDecimalSeparator {
			if decimalLocation == nil {
				// Prepend a 0 if the first character is a decimal point
				if currentOutput.isEmpty {
					currentOutput = "0"
				}
				return true
			} else {
				return false
			}
		}
		return true
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
