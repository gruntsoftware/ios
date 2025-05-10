import UIKit

class SyncProgressHeaderView: UITableViewCell, Subscriber {
	@IBOutlet var headerLabel: UILabel!
	@IBOutlet var timestampLabel: UILabel!
    @IBOutlet var blockheightLabel: UILabel!
	@IBOutlet var progressView: UIProgressView!
	@IBOutlet var noSendImageView: UIImageView!

	private let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("MMM d, yyyy h a")
		return df
	}()

	var progress: CGFloat = 0.0 {
		didSet {
			progressView.alpha = 1.0
			progressView.progress = Float(progress)
			progressView.setNeedsDisplay()
		}
	}
    

	var headerMessage: SyncState = .success {
		didSet {
			switch headerMessage {
			case .connecting:
                headerLabel.text = "Connecting..."
                headerLabel.textColor = BrainwalletUIColor.warn
			case .syncing: headerLabel.text = "Syncing..."
                headerLabel.textColor = BrainwalletUIColor.content
			case .success:
				headerLabel.text = ""
                headerLabel.textColor = BrainwalletUIColor.content
			}
			headerLabel.setNeedsDisplay()
		}
	}

	var timestamp: UInt32 = 0 {
		didSet {
			timestampLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
            timestampLabel.textColor = BrainwalletUIColor.content
			timestampLabel.setNeedsDisplay()
		}
	}
    
    var blockNumberString = "" {
        didSet {
            blockheightLabel.text = blockNumberString
            print("::: blockheightLabel.text:\(blockNumberString)")
            blockheightLabel.textColor = BrainwalletUIColor.content
            blockheightLabel.setNeedsDisplay()
        }
    }


	var isRescanning: Bool = false {
		didSet {
			if isRescanning {
				headerLabel.text = "Rescanning..."
				timestampLabel.text = ""
                blockheightLabel.text = ""
				progressView.alpha = 0.0
				noSendImageView.alpha = 1.0
			} else {
				headerLabel.text = ""
				timestampLabel.text = ""
                blockheightLabel.text = ""
				progressView.alpha = 1.0
				noSendImageView.alpha = 0.0
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
        progressView.trackTintColor = BrainwalletUIColor.background
        progressView.progressTintColor = BrainwalletUIColor.content
        noSendImageView.tintColor = BrainwalletUIColor.content
        noSendImageView.backgroundColor = BrainwalletUIColor.surface
        self.backgroundColor = BrainwalletUIColor.surface
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
