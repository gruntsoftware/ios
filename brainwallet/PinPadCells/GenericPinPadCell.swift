//
//  GenericPinPadCell.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import UIKit

class GenericPinPadCell: UICollectionViewCell {
    var text: String? {
        didSet {
            if text == deleteKeyIdentifier {
                imageView.image = #imageLiteral(resourceName: "Delete")
                topLabel.text = ""
                centerLabel.text = ""
            } else {
                imageView.image = nil
                topLabel.text = text
                centerLabel.text = text
            }
            setAppearance()
            setSublabel()
        }
    }

    let sublabels = [
        "2": "",
        "3": "",
        "4": "",
        "5": "",
        "6": "",
        "7": "",
        "8": "",
        "9": ""
    ]

    override var isHighlighted: Bool {
        didSet {
            guard text != "" else { return } // We don't want the blank cell to highlight
            setAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    let topLabel = UILabel(font: .customBody(size: 28.0))
    let centerLabel = UILabel(font: .customBody(size: 28.0))
    let sublabel = UILabel(font: .customBody(size: 11.0))
    let imageView = UIImageView()

    private func setup() {
        setAppearance()
        topLabel.textAlignment = .center
        centerLabel.textAlignment = .center
        sublabel.textAlignment = .center
        addSubview(topLabel)
        addSubview(centerLabel)
        addSubview(sublabel)
        addSubview(imageView)
        imageView.contentMode = .center
        addConstraints()
    }

    func addConstraints() {
        imageView.constrain(toSuperviewEdges: nil)
        centerLabel.constrain(toSuperviewEdges: nil)
        topLabel.constrain([
            topLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2.5)
        ])
        sublabel.constrain([
            sublabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            sublabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: -3.0)
        ])
    }

    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return topLabel.text
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.staticText
        }
        set {}
    }

    func setAppearance() {}
    func setSublabel() {}

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WhiteDecimalPad: GenericPinPadCell {
    override func setAppearance() {
        if isHighlighted {
            centerLabel.backgroundColor = BrainwalletUIColor.surface
            centerLabel.textColor = BrainwalletUIColor.content
        } else {
            centerLabel.backgroundColor = BrainwalletUIColor.surface
            centerLabel.textColor = BrainwalletUIColor.content
        }
    }

    override func addConstraints() {
        centerLabel.constrain(toSuperviewEdges: nil)
        imageView.constrain(toSuperviewEdges: nil)
    }
}
