import SwiftUI

struct BuyTileView: View {
	let codeCellHeight = 28.0
	let codeCellWidth = 80.0
	let smallPad = 3.0
	let buttonRegularFont: Font = .barlowSemiBold(size: 18.0)

	private var code: String

	init(code: String) {
		self.code = code
	}

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 14.0)
                .foregroundColor(BrainwalletColor.surface)
				.frame(width: codeCellWidth,
				       height: codeCellHeight,
				       alignment: .center)
				.overlay {
					RoundedRectangle(cornerRadius: 14.0)
						.stroke(BrainwalletColor.content, lineWidth: 0.5)
						.frame(width: codeCellWidth,
						       height: codeCellHeight,
						       alignment: .center)
				}
			Text(code)
				.foregroundColor(BrainwalletColor.content)
				.font(buttonRegularFont)
				.frame(width: codeCellWidth,
				       height: codeCellHeight,
				       alignment: .center)
		}
		.frame(width: codeCellWidth,
		       height: codeCellHeight,
		       alignment: .center)
		.padding(.all, smallPad)
	}
}

#Preview {
	BuyTileView(code: "USD")
}
