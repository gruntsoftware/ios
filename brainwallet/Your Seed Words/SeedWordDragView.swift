import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DraggableSeedWord: Codable, Equatable, Transferable {
    var id: UUID
    var tagNumber: Int
    var word: String
    var doesMatch: Bool

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .draggableSeedWord)
    }
}

extension UTType {
    static var draggableSeedWord: UTType {
        UTType(importedAs: "com.gruntsoftware.brainwallet.draggableSeedWord")
    }
}

struct SeedWordDragView: View {
	let seedWord: [DraggableSeedWord]
    let genericPad = 7.0
    let wordPad = 4.0
	let cellHeight = 40.0
    let buttonSize = 17.0

    @State
    private var isDragging: Bool = false

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
                            .foregroundColor(BrainwalletColor.background.opacity(0.9))
						VStack {
							HStack {
                                Spacer()
                                Text(seedWord.first?.word ?? "")
									.font(.barlowRegular(size: 16.0))
									.foregroundColor(userPrefersDarkTheme ? .white :
                                        BrainwalletColor.content)
									.frame(height: cellHeight,
									       alignment: .leading)
                                    .padding([.leading, .trailing], wordPad)

                                Image(systemName: "square.grid.4x3.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .rotationEffect(Angle(degrees: 90))
                                    .font(.system(size: 11, weight: .ultraLight))
                                    .frame(width: buttonSize,
                                           height: buttonSize,
                                        alignment: .center)
                                    .foregroundColor(BrainwalletColor.content.opacity(0.5))
                                    .padding(.trailing, genericPad)
							}
						}
					}
				}
                .onTapGesture {
                    isDragging.toggle()
                }
				.frame(width: width, height: height)
			}
			.frame(width: width, height: height)
		}
	}
}
