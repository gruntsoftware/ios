import Foundation

class LocaleChangeViewModel: ObservableObject {
	// MARK: - Combine Variables

	@Published
	var displayName: String = ""

	init() {
		let currentLocale = Locale.current

        if let regionCodeID = currentLocale.region?.identifier,
		   let name = currentLocale.localizedString(forRegionCode: regionCodeID) {
			displayName = name
		} else {
			displayName = "-"
		}
	}
}
