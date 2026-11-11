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

    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: cellHeight / 2)
				.foregroundColor(BrainwalletColor.background.opacity(0.9))
			HStack {
				Spacer()
				Text(seedWord.first?.word ?? "")
					.modifier(BWIPSLight(size: 16.0))
					.foregroundColor(userPrefersDarkTheme ? .white :
																BrainwalletColor.content)
					.padding([.leading, .trailing], wordPad)

				Image(systemName: "square.grid.4x3.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.rotationEffect(Angle(degrees: 90))
					.modifier(BWIPSThin(size: 11.0))
					.frame(width: buttonSize,
						   height: buttonSize,
						   alignment: .center)
					.foregroundColor(BrainwalletColor.content.opacity(0.5))
					.padding(.trailing, genericPad)
			}
		}
		// Definite height so the view's bounds (and drag lift preview) equal the capsule
		.frame(maxWidth: .infinity)
		.frame(height: cellHeight)
	}
}
