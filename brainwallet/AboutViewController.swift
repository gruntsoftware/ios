import SafariServices
import UIKit

class AboutViewController: UIViewController {
	private var titleLabel = UILabel(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)
	private let logoBackground = UIView()
	private let blog = AboutCell(text: S.About.blog.localize())
	private let twitter = AboutCell(text: S.About.twitter.localize())
    private let bluesky = AboutCell(text: S.About.bluesky.localize())
	private let privacy = UIButton(type: .system)
    private let footer = UILabel(font: .customBody(size: 13.0), color: BrainwalletUIColor.content)
	override func viewDidLoad() {
		if #available(iOS 11.0, *),
		   let labelTextColor = UIColor(named: "labelTextColor"),
		   let backgroundColor = UIColor(named: "lfBackgroundColor")
		{
			titleLabel.textColor = labelTextColor
			privacy.tintColor = labelTextColor
			view.backgroundColor = backgroundColor
		} else {
			privacy.tintColor = BrainwalletUIColor.surface
			view.backgroundColor = BrainwalletUIColor.content
		}

		addSubviews()
		addConstraints()
		setData()
		setActions()
	}

	private func addSubviews() {
		view.addSubview(titleLabel)
		view.addSubview(logoBackground)
		view.addSubview(blog)
		view.addSubview(twitter)
		view.addSubview(bluesky)
		view.addSubview(privacy)
		view.addSubview(footer)
	}

	private func addConstraints() {
		titleLabel.constrain([
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2]),
		])
		logoBackground.constrain([
			logoBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: C.padding[3]),
			logoBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
			logoBackground.heightAnchor.constraint(equalTo: logoBackground.widthAnchor, multiplier: 1.0),
		])
		blog.constrain([
			blog.topAnchor.constraint(equalTo: logoBackground.bottomAnchor, constant: C.padding[2]),
			blog.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			blog.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
		twitter.constrain([
			twitter.topAnchor.constraint(equalTo: blog.bottomAnchor, constant: C.padding[2]),
			twitter.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			twitter.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
        bluesky.constrain([
            bluesky.topAnchor.constraint(equalTo: twitter.bottomAnchor, constant: C.padding[2]),
            bluesky.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bluesky.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
		privacy.constrain([
			privacy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			privacy.topAnchor.constraint(equalTo: bluesky.bottomAnchor, constant: C.padding[2]),
		])
		footer.constrain([
			footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			footer.topAnchor.constraint(equalTo: privacy.bottomAnchor),
			footer.heightAnchor.constraint(equalToConstant: 80),
		])
	}

	private func setData() {
		titleLabel.text = S.Settings.socialLinks.localize()
		privacy.setTitle(S.About.privacy.localize(), for: .normal)
		privacy.titleLabel?.font = UIFont.customBody(size: 13.0)
		footer.textAlignment = .center
		footer.numberOfLines = 4
		footer.text = String(format: S.About.footer.localize(), AppVersion.string)
	}

	private func setActions() {
		blog.button.tap = strongify(self) { myself in
			myself.presentURL(string: "https://brainwallet.co")
		}
		twitter.button.tap = strongify(self) { myself in
			myself.presentURL(string: "http://x.com/Brainwallet_App")
		}
		bluesky.button.tap = strongify(self) { myself in
			myself.presentURL(string: "https://tr.ee/beiPaJSwbl")
		}
		privacy.tap = strongify(self) { myself in
			myself.presentURL(string: "https://brainwallet.co/privacy-policy.html")
		}
	}

	private func presentURL(string: String) {
		let vc = SFSafariViewController(url: URL(string: string)!)
		present(vc, animated: true, completion: nil)
	}
}
