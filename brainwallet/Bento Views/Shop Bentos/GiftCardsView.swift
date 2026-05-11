//
//  GiftCardsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 4/26/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
 

import SwiftUI

struct GiftCardsView: View {
          
    
    @State
    private var shouldAnimate: Bool = false
    
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                HStack {
                    VStack(alignment: .trailing) {
                        SingleGiftCardView(giftCardImage: "visa_logo",
                                           gradient: BrainwalletGradient.blueCard,
                                           rotationAngle: 20.0)
                        .frame(width: 100, height: 63.05)
                        .offset(x: shouldAnimate ? -15 :  145, y: 10.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                shouldAnimate = true
                            }
                        }
                    }
                }
                .frame(width: width)
                
                HStack {
                    VStack(alignment: .trailing) {
                        
                        SingleGiftCardView(giftCardImage: "je_logo",
                                           gradient: BrainwalletGradient.orangeCard,
                                           rotationAngle: 20.0)
                        .frame(width: 100, height: 63.05)
                        .offset(x: shouldAnimate ? 30 :  105, y: -2.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                shouldAnimate = true
                            }
                        }
                        Spacer()
                    }
                }
                .frame(width: width)

                
                HStack {
                    VStack(alignment: .trailing) {
                        Spacer()
                        SingleGiftCardView(giftCardImage: "amazon_logo",
                                           gradient: BrainwalletGradient.grayCard,
                                           rotationAngle: -20.0)
                        .frame(width: 100, height: 63.05)
                        .offset(x: shouldAnimate ? 25 :  105, y: 15.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.4)) {
                                shouldAnimate = true
                            }
                        }
                        
                    }
                }
                .frame(width: width)
                
                
            }
        }
    }
}
 


struct SingleGiftCardView: View {
    
    let giftCardImage: String
    
    let gradient: RadialGradient

    let rotationAngle: Double
     
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(gradient)
                        .frame(width: width, height: width * 0.6305)
                        .rotationEffect(Angle(degrees: rotationAngle))
                    Image(giftCardImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: width * 0.6)
                        .rotationEffect(Angle(degrees: rotationAngle))
                }
        }
    }
}
