//
//  SyncSubBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 26/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SyncSubBentoView: View {

    @ObservedObject
    var viewModel: SyncSubBentoViewModel

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

    private let progressBarHeight: CGFloat = 14.0
    private let progressIconSize: CGFloat = 13.0

    init(viewModel: SyncSubBentoViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        GeometryReader { _ in
            ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()

                                Text(viewModel.syncStateMessage)
                                    .font(.ibmPlexSansSemiBold(size: 11.0))
                                    .frame(alignment: .trailing)
                                    .foregroundColor(.white)
                            }

                            HStack {
                                Spacer()

                                Text(String(localized:"Last block: ") + viewModel.lastFoundBlockHeightString)
                                    .font(.ibmPlexSansLight(size: 11.0))
                                    .frame(alignment: .trailing)
                                    .foregroundColor(.white)

                            }
                            HStack {
                                Spacer()

                                Text(String(localized:"Date: ") + viewModel.formattedTimestamp)
                                    .font(.ibmPlexSansThin(size: 11.0))
                                    .frame(alignment: .trailing)
                                    .foregroundColor(.white)

                            }

                            HStack {

                                Text(String(format: "%3.2f %%", viewModel.progress * 100))
                                    .font(.ibmPlexSansBold(size: 10.0))
                                    .frame(width: 50.0, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 4.0)
                                Text("Block: \(viewModel.currentBlockHeightString)")
                                    .font(.ibmPlexSansThin(size: 11.0))
                                    .frame(alignment: .leading)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Send")
                                    .font(.ibmPlexSansThin(size: 11.0))
                                    .frame(alignment: .center)
                                    .foregroundColor(.white)

                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.error)

                                Text("Receive")
                                    .font(.ibmPlexSansThin(size: 11.0))
                                    .frame(alignment: .center)
                                    .foregroundColor(.white)

                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.affirm)

                            }
                            .coordinateSpace(name: "progresslabels")
                            HStack {
                                ProgressView(value: viewModel.progress)
                                    .progressViewStyle(.linear)
                                    .accentColor(BentoColor.progressGreen1)
                                    .padding(.bottom, 8)
                            }

                        }
                        .padding(.bottom, 8)
                        .opacity(viewModel.isSyncing ? 1.0 : 0.0)

                    }
        }
    }
}
