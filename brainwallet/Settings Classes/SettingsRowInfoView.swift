//
//  SettingsRowInfoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsRowInfoView: View {
    
    private let titleText: String
    private let detailText: String
    private let rowHeight: CGFloat
    private let nearBlackbackgroundColor = BrainwalletColor.nearBlack
    private let nearBlackforegroundColor = Color.white
    private var backgroundColor = BrainwalletColor.surface

    private let nearBlackStyle: Bool
    
    let titleFont: Font = .barlowSemiBold(size: 20.0)
    let detailFont: Font = .barlowLight(size: 14.0)

    init(title: String, detail: String, rowHeight: CGFloat = 44.0, nearBlackStyle: Bool = false) {
        self.titleText = title
        self.detailText = detail
        self.rowHeight = rowHeight
        self.nearBlackStyle = nearBlackStyle
        
        
        if nearBlackStyle {
            backgroundColor = nearBlackbackgroundColor
        } else {
            backgroundColor = BrainwalletColor.surface
        }
        
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                       Text(titleText)
                                .font(titleFont)
                                .foregroundColor( nearBlackStyle ? .white : BrainwalletColor.content)
                                .frame(width: width * 0.3, alignment: .leading)
                                .padding(.leading, 16.0)
                        Spacer()
                           
                        Text(detailText)
                                .font(detailFont)
                                .foregroundColor( nearBlackStyle ? .white : BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 16.0)
                    }
                    .frame(height: rowHeight)
                    .padding(.trailing, 16.0)
                    Spacer()
                    Divider()
                }
                .frame(height: rowHeight, alignment: .leading)
            }
        }
    }
}
struct SettingsRowInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowInfoView(title: "TEST TITLE", detail: "boo bop", rowHeight: 44.0, nearBlackStyle: true)
    }
}

 
