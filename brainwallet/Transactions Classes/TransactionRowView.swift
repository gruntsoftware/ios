//
//  TransactionRowView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
 
struct TransactionRowView: View {
    
    @State
    private var isReceived: Bool = false
    
    @State
    private var filterMode: FilterTransactionMode = .all
    
    @State
    private var modeState = 0
    
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                BrainwalletColor.affirm.edgesIgnoringSafeArea(.all)
                HStack {
                    VStack {
                        Image(systemName: isReceived ? "arrow.up.circlepath" : "arrow.down.circlepath")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isReceived ? BrainwalletColor.affirm : BrainwalletColor.content)
                            .padding()
                    }
                    VStack {
                        Text(isReceived ?  S.Transaction.receivedStatus.localize() : S.Transaction.sendingStatus.localize())
                            .font(.title2)
                            .foregroundColor(BrainwalletColor.content)
                        Text("IS PROGRESSING...")
                            .font(.title2)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    VStack {}
                }
            }
        }
    }
    
}
