import UIKit

enum ModalHeaderViewStyle {
    case light
    case dark
}

class ModalHeaderView: UIView {
    // MARK: - Public

    var closeCallback: (() -> Void)? {
        didSet { close.tap = closeCallback }
    }

    init(title: String, style: ModalHeaderViewStyle, faqInfo _: (Store, String)? = nil, showCloseButton: Bool = true) {
        self.title.text = title
        self.style = style

        self.showCloseButton = showCloseButton
        super.init(frame: .zero)
        setupSubviews()
        setColors()
    }

    let showCloseButton: Bool

    // MARK: - Private

    private let title = UILabel(font: .barlowSemiBold(size: 17.0))
    private let close = UIButton.close
    private let border = UIView()
    private let buttonSize: CGFloat = 44.0
    private let style: ModalHeaderViewStyle

    private func setupSubviews() {
        addSubview(title)
        addSubview(border)
        if showCloseButton {
            addSubview(close)
            close.constrain([
                close.constraint(.leading, toView: self, constant: 10.0),
                close.constraint(.centerY, toView: self, constant: 10.0),
                close.constraint(.height, constant: buttonSize),
                close.constraint(.width, constant: buttonSize)
            ])
        }

        title.constrain([
            title.constraint(.centerX, toView: self, constant: 0.0),
            title.constraint(.centerY, toView: self, constant: 0.0)
        ])
        border.constrain([
            border.constraint(.height, constant: 1.0)
        ])
        border.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
    }

    private func setColors() {
        backgroundColor = BrainwalletUIColor.surface
        switch style {
        case .light:
            title.textColor = BrainwalletUIColor.content
            close.tintColor = BrainwalletUIColor.content
        case .dark:
            border.backgroundColor = BrainwalletUIColor.surface
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
