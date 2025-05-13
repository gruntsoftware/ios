import Foundation

class LanguageSelectionViewModel {
	var localizations: [String] {
        
        debugPrint(":::\(Bundle.main.localizations)" )
		return Bundle.main.localizations
	}

	func setLanguage(code: String) {
		UserDefaults.selectedLanguage = code
		UserDefaults.standard.synchronize()
		Bundle.setLanguage(code)

		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .languageChangedNotification,
			                                object: nil,
			                                userInfo: nil)
		}
	}
}
