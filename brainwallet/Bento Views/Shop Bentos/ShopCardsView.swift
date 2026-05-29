//
//  ShopCardsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 4/26/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
 

import SwiftUI

struct ShopCardsView: View {
    
    @State
    private var shouldAnimate: Bool = false
    
    @State
    private var image1 = UIImage(named: "bw-placeholder")!
    
    @State
    private var image2 = UIImage(named: "bw-placeholder")!
    
    @State
    private var image3 = UIImage(named: "bw-placeholder")!
  
    @ObservedObject
    var shopViewModel: ShopBentoViewModel
 
    private func loadImages() {
        let images = shopViewModel.cardImages
        image1 = images?[safe: 0] ?? UIImage(named: "bw-placeholder")!
        image2 = images?[safe: 1] ?? UIImage(named: "bw-placeholder")!
        image3 = images?[safe: 2] ?? UIImage(named: "bw-placeholder")!
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width

            ZStack {
                HStack {
                    VStack(alignment: .trailing) {
                        SingleShopCardView(cardUIImage: image1,
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
                        
                        SingleShopCardView(cardUIImage: image2,
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
                        SingleShopCardView(cardUIImage: image3,
                                           gradient: BrainwalletGradient.blueCard,
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
        .onChange(of: shopViewModel.cardsAreLoaded) { _, newVersion in
            
            if shopViewModel.cardsAreLoaded {
                loadImages()
                withAnimation(.easeInOut(duration: 2.0)) {
                    shouldAnimate = true
                }
            }
            
        }
    }
}
 
struct SingleShopCardView: View {
    
    let cardUIImage: UIImage
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
                
                Image(uiImage: cardUIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width * 0.6305)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .rotationEffect(Angle(degrees: rotationAngle))
            }
        }
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
