//
//  SettingsRowFooterView.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsRowFooterView: View {
    
    private let titleText: String
    private let detailText: String
    private let rowHeight: CGFloat
    private let nearBlackbackgroundColor = BrainwalletColor.nearBlack
    private let nearBlackforegroundColor = Color.white
    
    let titleFont: Font = .barlowSemiBold(size: 18.0)
    let detailFont: Font = .barlowLight(size: 14.0)

    init(title: String, detail: String, rowHeight: CGFloat = 40.0) {
        self.titleText = title
        self.detailText = detail
        self.rowHeight = rowHeight
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            ZStack {
                BrainwalletColor.nearBlack.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                       Text(titleText)
                                .font(titleFont)
                                .foregroundColor( .white)
                                .frame(width: width * 0.3, alignment: .leading)
                                .padding(.leading, 16.0)
                        Spacer()
                           
                        Text(detailText)
                                .font(detailFont)
                                .foregroundColor( .white)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 16.0)
                    }
                    .padding(.trailing, 16.0)
                }
                .frame(height: rowHeight, alignment: .leading)
            }
        }
    }
}
struct SettingsRowFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowFooterView(title: "TEST TITLE", detail: "boo bop")
    }
}

 
