import Foundation
import SwiftUI

struct SeedWord: Identifiable, Equatable {
	let id = UUID()
	let word: String
	let tagNumber: Int
}

struct SeedWordView: View {
	let seedWord: String
	let wordNumber: Int
    let genericPad = 16.0
	let cellHeight = 40.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

	var body: some View {
		GeometryReader { geometry in

			let width = geometry.size.width
			let height = geometry.size.height
			ZStack {
				VStack {
					ZStack {
						RoundedRectangle(cornerRadius: cellHeight / 2)
							.frame(height: cellHeight, alignment: .center)
                            .foregroundColor(BrainwalletColor.background.opacity(0.4))

						Text("\(seedWord)")
							.frame(height: cellHeight, alignment: .center)
                            .modifier(BWIPSLight(size: 16.0))
                            .foregroundColor(userPrefersDarkTheme ? .white :
                                BrainwalletColor.content)
						VStack {
							HStack {
								Text("\(wordNumber)")
									.modifier(BWIPSRegular(size: 12.0))
									.foregroundColor(userPrefersDarkTheme ? .white :
                                        BrainwalletColor.content)
									.frame(width: 22,
									       height: cellHeight,
									       alignment: .leading)
                                    .padding(.leading, genericPad)
                                    .offset(x: -4, y: -4)
								Spacer()
							}
						}
					}
				}
				.frame(width: width, height: height)
				.padding(.all, genericPad)
			}
			.frame(width: width, height: height)
		}
	}
}
