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
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                        VStack {
                            Spacer()

                            HStack {
                                Spacer()

                                Text(String(localized:"Block: ") + viewModel.blockHeightString)
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .frame(alignment: .trailing)
                                    .foregroundColor(.white)
                            }
                            HStack {
                                Spacer()

                                Text(String(localized:"Timestamp: ") + viewModel.formattedTimestamp)
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .frame(alignment: .trailing)
                                    .foregroundColor(.white)
                            }
                            HStack {
                                ProgressView(value: viewModel.progress)
                                    .progressViewStyle(.linear)
                                    .accentColor(.white)
                            }
                            HStack {
                                Spacer()
                                Text("SEND")
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .frame(alignment: .center)
                                    .foregroundColor(.white)

                                Image(systemName: "nosign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.error)

                                Text("RECEIVE")
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .frame(alignment: .center)
                                    .foregroundColor(.white)

                                Image(systemName: "square.and.arrow.down")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: progressIconSize,
                                           height: progressIconSize,
                                           alignment: .trailing)
                                    .foregroundColor(BrainwalletColor.affirm)

                            }
                            .coordinateSpace(name: "progresslabels")
                        }
                        .padding(.bottom, 8)
                    }
        }
    }
}
