//
//  NewSyncProgressView.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct NewSyncProgressView: View {
    
    @ObservedObject
    var viewModel: NewSyncProgressViewModel
    
    @State
    private var headerText  = ""
    
    @State
    private var timestampText  = ""
    @State
    private var blockheightText  = ""
    
    @State
    private var progressValue: Float = 0.0
    
    @State
    private var isSendAvailable: Bool = false
    
    private let progressViewHeight: CGFloat = 55.0
    private let progressBarHeight: CGFloat = 14.0
    private let progressIconSize: CGFloat = 16.0
    
    init(viewModel: NewSyncProgressViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(.linear)
                            .accentColor(BrainwalletColor.grape)
                            .frame(height: progressBarHeight)
                            .padding([.leading,.trailing], 8.0)
                    }
                    .frame(height: progressBarHeight)
                    HStack {
                        VStack {
                            Text(String(localized:"Block time: ") + viewModel.formattedTimestamp)
                                .font(.caption)
                                .frame(width: 210.0, alignment: .leading)
                                .foregroundColor(BrainwalletColor.content)
                            Text(String(localized:"Last block: ") + viewModel.blockHeightString)
                                .font(.caption)
                                .frame(width: 210.0, alignment: .leading)
                                .foregroundColor(BrainwalletColor.content)
                            Spacer()
                        }
                        .padding(.leading, 8.0)
                        
                        Spacer()
                        VStack {
                            HStack {
                                Text("SEND")
                                    .font(.caption)
                                    .frame(width: 70.0, alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.content)
                                Image(systemName: "nosign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.error)
                            }
                            HStack {
                                Text("RECEIVE")
                                    .font(.caption)
                                    .frame(width: 70.0, alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.content) 

                                Image(systemName: "square.and.arrow.down")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.affirm)
                            }
                            Spacer()
                        }
                        .padding(.trailing, 8.0)
                    }
                    Divider()
                        .frame(height: 2.0)
                        .background(BrainwalletColor.midnight.opacity(0.8))
                }
                .frame(width: width, height: progressViewHeight)
            }
        }
    }
}

//
// import UIKit
//
// class SyncProgressHeaderView: UITableViewCell, Subscriber {
//    @IBOutlet var headerLabel: UILabel!
//    @IBOutlet var timestampLabel: UILabel!
//    @IBOutlet var blockheightLabel: UILabel!
//    @IBOutlet var progressView: UIProgressView!
//    @IBOutlet var noSendImageView: UIImageView!
//
//    private let dateFormatter: DateFormatter = {
//        let df = DateFormatter()
//        df.setLocalizedDateFormatFromTemplate("MMM d, yyyy h a")
//        return df
//    }()
//
//    var progress: CGFloat = 0.0 {
//        didSet {
//            progressView.alpha = 1.0
//            progressView.progress = Float(progress)
//            progressView.setNeedsDisplay()
//        }
//    }
//    
//
//    var headerMessage: SyncState = .success {
//        didSet {
//            switch headerMessage {
//            case .connecting:
//                headerLabel.text = String(localized: "Connecting...", bundle: .main)
//                headerLabel.textColor = BrainwalletUIColor.warn
//            case .syncing: headerLabel.text = String(localized: "Syncing...", bundle: .main)
//                headerLabel.textColor = BrainwalletUIColor.content
//            case .success:
//                headerLabel.text = ""
//                headerLabel.textColor = BrainwalletUIColor.content
//            }
//            headerLabel.setNeedsDisplay()
//        }
//    }
//
//    var timestamp: UInt32 = 0 {
//        didSet {
//            timestampLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
//            timestampLabel.textColor = BrainwalletUIColor.content
//            timestampLabel.setNeedsDisplay()
//        }
//    }
//    
//    var blockNumberString = "" {
//        didSet {
//            blockheightLabel.text = blockNumberString
//            blockheightLabel.textColor = BrainwalletUIColor.content
//            blockheightLabel.setNeedsDisplay()
//        }
//    }
//
//
//    var isRescanning: Bool = false {
//        didSet {
//            if isRescanning {
//                headerLabel.text = String(localized: "Rescanning...", bundle: .main)
//                timestampLabel.text = ""
//                blockheightLabel.text = ""
//                progressView.alpha = 0.0
//                noSendImageView.alpha = 1.0
//            } else {
//                headerLabel.text = ""
//                timestampLabel.text = ""
//                blockheightLabel.text = ""
//                progressView.alpha = 1.0
//                noSendImageView.alpha = 0.0
//            }
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
//        progressView.trackTintColor = BrainwalletUIColor.background
//        progressView.progressTintColor = BrainwalletUIColor.content
//        noSendImageView.tintColor = BrainwalletUIColor.content
//        noSendImageView.backgroundColor = BrainwalletUIColor.surface
//        self.backgroundColor = BrainwalletUIColor.surface
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
// }
