//
//  SettingsRowThemeView.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsRowThemeView: View {
    
    private let titleText: String
    private let rowHeight: CGFloat
    private let accessoryEnum: SettingsRowEnum
    
    let titleFont: Font = .barlowSemiBold(size: 22.0)
    let buttonSize = 22.0

    @Binding
    var didActivate: Bool
     
    init(title: String,
         rowHeight: CGFloat = 44.0,
         accessoryEnum: SettingsRowEnum,
         didActivate: Binding<Bool>) {
        self.titleText = title
        self.rowHeight = rowHeight
        self.accessoryEnum = accessoryEnum
        _didActivate = didActivate
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text(titleText)
                            .font(titleFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16.0)
                        Spacer()
                        Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                        didActivate.toggle()
                                }
                        }) {
                            
                            Image(systemName: didActivate ? "sun.max.circle" : "moon.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: width * 0.5, height: buttonSize,
                                       alignment: .trailing)
                                .foregroundColor(BrainwalletColor.content)
                                .tint(BrainwalletColor.surface)
                        }
                        .frame(height: rowHeight, alignment: .trailing)
                       
                        .padding(.trailing, 18.0)
                    }
                    .padding(.trailing, 18.0)
                    Spacer()
                    Divider()
                }
                .frame(height: rowHeight, alignment: .leading)
            }
        }
    }
}
 

 
