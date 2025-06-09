//
//  LoginView.swift
//  brainwallet
//
//  Created by Kerry Washington on 12/25/23.
//
import SwiftUI

struct LoginView: View {
	@ObservedObject
	var viewModel: LockScreenViewModel

	init(viewModel: LockScreenViewModel) {
		self.viewModel = viewModel

		/// lockScreenHeaderView
	}

	var body: some View {
		GeometryReader { _ in
			ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
				VStack {
					Spacer()
				}
			}
		}
	}
}
