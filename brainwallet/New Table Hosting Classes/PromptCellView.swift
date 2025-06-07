//
//  PromptCellView.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct PromptCellView: View {
    
    // MARK: - Combine Variables
    
    @ObservedObject
    var viewModel: PromptCellViewModel
    
    @State
    private var userDidTapClose: Bool = false
    
    @State
    private var userDidTapContinue: Bool = false
    
    init(viewModel: PromptCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()

                    // Title
                    HStack(alignment: .top, spacing: 1.0) {
                        Text("\(viewModel.promptType.title)")
                            .frame(width: 190.0, alignment: .leading)
                            .font(Font(UIFont.barlowSemiBold(size: 20.0)))
                            .foregroundColor(BrainwalletColor.content)
                            .padding(20.0)
                        
                        Spacer()
                        Image(systemName: viewModel.promptType.systemImageName ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44.0,
                                   height: 44.0)
                            .foregroundColor(BrainwalletColor.background)
                            .padding(20.0)
                    }
                    .padding([.leading, .trailing], 10.0)
                    .padding(.bottom, 5.0)
                    HStack(alignment: .top, spacing: 1.0) {
                        Text("\(viewModel.promptType.body)")
                            .font(Font(UIFont.barlowRegular(size: 18.0)))
                            .foregroundColor(BrainwalletColor.content)
                            .padding(20.0)
                        Spacer()
                    }
                    .padding([.leading, .trailing], 10.0)
                    .padding(.bottom, 5.0)
                    
                    HStack(alignment: .top, spacing: 1.0) {
                        Spacer()
                        Button(action: {
                            userDidTapClose.toggle()
                        }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 25.0,
                                           height: 25.0,
                                           alignment: .center)
                                    .foregroundColor(BrainwalletColor.content)
                                    .padding()
                        }
                    }
                    .padding([.leading, .trailing], 10.0)
                    .padding(.bottom, 5.0)
                    .frame(height: 40.0)
                    Divider()
                        .frame(height: 1.0)
                        .background(BrainwalletColor.border)
                        .padding([.leading, .trailing], 10.0)
                }
            }
        }
    }
}
