import UIKit

class ModalViewController: UIViewController, Subscriber {
	// MARK: - Public

	var childViewController: UIViewController

	init<T: UIViewController>(childViewController: T, store: Store) where T: ModalDisplayable {
		self.childViewController = childViewController
		modalInfo = childViewController
		self.store = store
		header = ModalHeaderView(title: modalInfo.modalTitle, style: .dark)
		super.init(nibName: nil, bundle: nil)
	}

	// MARK: - Private

	private let modalInfo: ModalDisplayable
    private let headerHeight: CGFloat = 50.0
    fileprivate let header: ModalHeaderView
    private let swipeGestureRecognizer = UISwipeGestureRecognizer()

	private let store: Store
	private let scrollView = UIScrollView()
	private let scrollViewContent = UIView()

	deinit {
		store.unsubscribe(self)
	}

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
        view.addSubview(header)
		view.addSubview(scrollView)
		scrollView.addSubview(scrollViewContent)
		addChild(childViewController)
		scrollViewContent.addSubview(childViewController.view)
		childViewController.didMove(toParent: self)
	}

	private func addConstraints() {
		header.constrain([
			header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			header.bottomAnchor.constraint(equalTo: scrollView.topAnchor),
			header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			header.heightAnchor.constraint(equalToConstant: headerHeight)
		])
		scrollView.constrain([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		scrollViewContent.constrain([
			scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
			scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])

		childViewController.view.constrain(toSuperviewEdges: nil)

		// Two stage layout is required here because we need the height constant
		// of the content at initial layout
		view.layoutIfNeeded()
		let height = scrollViewContent.bounds.size.height + 60.0
		let minHeight = scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
		let midHeight = scrollView.heightAnchor.constraint(equalTo: scrollViewContent.heightAnchor)
		let maxHeight = scrollView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, constant: -headerHeight)
		midHeight.priority = UILayoutPriority.defaultLow
		scrollView.constrain([
			minHeight,
			midHeight,
			maxHeight
		])
	}

	private func setInitialData() {
		view.backgroundColor = .clear
        scrollView.backgroundColor =  BrainwalletUIColor.surface

		scrollView.delaysContentTouches = false
		if var modalPresentable = childViewController as? ModalPresentable {
			modalPresentable.parentView = view
		}

        swipeGestureRecognizer.delegate = self
        swipeGestureRecognizer.addTarget(self, action: #selector(didSwipe))
		view.addGestureRecognizer(swipeGestureRecognizer)
		store.subscribe(self, name: .blockModalDismissal, callback: { [weak self] _ in
			self?.swipeGestureRecognizer.isEnabled = false
		})

		store.subscribe(self, name: .unblockModalDismissal, callback: { _ in
			self.swipeGestureRecognizer.isEnabled = true
		})
		addTopCorners()
		header.closeCallback = { [weak self] in
			if let delegate = self?.transitioningDelegate as? ModalTransitionDelegate {
				delegate.reset()
			}
			self?.dismiss(animated: true, completion: {})
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.15
		view.layer.shadowRadius = 4.0
		view.layer.shadowOffset = .zero
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

    @objc
    private func didSwipe() {
        guard let modalTransitionDelegate = transitioningDelegate as? ModalTransitionDelegate else { return }
        modalTransitionDelegate.reset()
        dismiss(animated: true, completion: nil)
    }

	private func addTopCorners() {
		let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: modalCorner / 2 , height: modalCorner / 2 )).cgPath
		let maskLayer = CAShapeLayer()
		maskLayer.path = path
		header.layer.mask = maskLayer
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension ModalViewController: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let location = gestureRecognizer.location(in: view)
        if location.y < self.view.frame.minY {
			return true
		} else {
			return false
		}
	}
}
