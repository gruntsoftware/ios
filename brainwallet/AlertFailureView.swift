import SwiftUI

struct AlertFailureView: View {
	let alertFailureType: AlertFailureType

	let errorMessage: String

	init(alertFailureType: AlertFailureType, errorMessage: String) {
		self.alertFailureType = alertFailureType
		self.errorMessage = errorMessage
	}

	var body: some View {
		VStack {

			Divider()
				.frame(maxHeight: 1.0)
                .background(BrainwalletColor.surface)

			Image(systemName: "nosign")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 40,
				       height: 40,
				       alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
				.foregroundColor(.white)
				.padding()

			Text(self.errorMessage.localizedCapitalized)
				.foregroundColor(.white)
				.font(Font(UIFont.barlowSemiBold(size: 16.0)))
				.padding(.bottom, 60)
		}
		.background(Color(UIColor.gray))
		.cornerRadius(6.0)
	}
}

struct AlertFailureView_Previews: PreviewProvider {
	static let alert = AlertFailureType.failedResolution
	static let errorMessage = "Test Error"

	static var previews: some View {
		AlertFailureView(alertFailureType: alert, errorMessage: errorMessage)
			.environment(\.locale, .init(identifier: "en"))
	}
}
