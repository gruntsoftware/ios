import UIKit

private let itemHeight: CGFloat = 50.0

class EnterPhraseCollectionViewController: UICollectionViewController {
	// MARK: - Public

	var didFinishPhraseEntry: ((String) -> Void)?
	var height: CGFloat {
		return itemHeight * 4.0
	}

	#if Debug || Testflight
		// let mockPhraseString = MockSeeds.mockPhraseModelX
	#endif

	init(walletManager: WalletManager) {
		self.walletManager = walletManager
		let layout = UICollectionViewFlowLayout()
		let screenWidth = UIScreen.main.safeWidth
		layout.itemSize = CGSize(width: (screenWidth - C.padding[4]) / 3.0, height: itemHeight)
		layout.minimumLineSpacing = 0.0
		layout.minimumInteritemSpacing = 0.0
		layout.sectionInset = .zero
		super.init(collectionViewLayout: layout)
	}

	// MARK: - Private

	private let cellIdentifier = "CellIdentifier"
	private let walletManager: WalletManager
	private var phrase: String {
		return (0 ... 11).map { index in
			guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? EnterPhraseCell else { return "" }
			return phraseCell.textField.text ?? ""
		}.joined(separator: " ")
	}

	override func viewDidLoad() {
		collectionView = NonScrollingCollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
		collectionView?.backgroundColor = BrainwalletUIColor.surface
		collectionView?.register(EnterPhraseCell.self, forCellWithReuseIdentifier: cellIdentifier)
		collectionView?.delegate = self
		collectionView?.dataSource = self
        collectionView?.layer.borderColor = BrainwalletUIColor.border.cgColor
		collectionView?.layer.borderWidth = 1.0
		collectionView?.layer.cornerRadius = 8.0
		collectionView?.isScrollEnabled = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		becomeFirstResponder(atIndex: 0)
	}

	// MARK: - UICollectionViewDataSource

	override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
		return 12
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
		guard let enterPhraseCell = item as? EnterPhraseCell else { return item }
		enterPhraseCell.index = indexPath.row
		enterPhraseCell.didTapNext = { [weak self] in
			self?.becomeFirstResponder(atIndex: indexPath.row + 1)
		}
		enterPhraseCell.didTapPrevious = { [weak self] in
			self?.becomeFirstResponder(atIndex: indexPath.row - 1)
		}
		enterPhraseCell.didTapDone = { [weak self] in
			guard let phrase = self?.phrase
			else {
				NSLog("Phrase not initialized")
				return
			}
			#if Debug || Testflight
				// phrase = MockSeeds.mockPhraseModelX
			#endif
			self?.didFinishPhraseEntry?(phrase)
		}
		enterPhraseCell.isWordValid = { [weak self] word in
			guard let myself = self else { return false }
			return myself.walletManager.isWordValid(word)
		}
		enterPhraseCell.didEnterSpace = {
			enterPhraseCell.didTapNext?()
		}

		if indexPath.item == 0 {
			enterPhraseCell.disablePreviousButton()
		} else if indexPath.item == 11 {
			enterPhraseCell.disableNextButton()
		}
		return item
	}

	// MARK: - Extras

	private func becomeFirstResponder(atIndex: Int) {
		guard let phraseCell = collectionView?.cellForItem(at: IndexPath(item: atIndex, section: 0)) as? EnterPhraseCell else { return }
		phraseCell.textField.becomeFirstResponder()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
