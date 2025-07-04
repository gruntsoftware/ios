import Foundation
import SwiftUI
import UIKit

enum CreateStepConfig {
	case intro
	case checkboxes
	case seedPhrase
	case finished

	var backgroundColor: Color {
		switch self {
		case .intro:
			return .white
		case .checkboxes:
			return .white
		case .seedPhrase:
			return .white
		case .finished:
			return .white
		}
	}

	var mainTitle: String {
		switch self {
		case .intro:
			return "Introduction to Brainwallet"
		case .checkboxes:
			return "Join the Community"
		case .seedPhrase:
			return "Don't lose this!"
		case .finished:
			return "Check out your Brainwallet"
		}
	}

	var detaiedlMessage: String {
		switch self {
		case .intro:
			return "You will need 5 mins, a private area and way to take this information down."
		case .checkboxes:
			return "You will need 5 mins, a private area and way to take this information down."
		case .seedPhrase:
			return "You will need 5 mins, a private area and way to take this information down."
		case .finished:
			return "You will need 5 mins, a private area and way to take this information down."
		}
	}

	var extendedMessage: String {
		switch self {
		case .intro:
			return "You will need 5 mins, a private area and way to take this information down."
		case .checkboxes:
			return "You will need 5 mins, a private area and way to take this information down."
		case .seedPhrase:
			return "You will need 5 mins, a private area and way to take this information down."
		case .finished:
			return "You will need 5 mins, a private area and way to take this information down."
		}
	}

	var bullet1: String {
		switch self {
		case .intro:
			return "You will need 5 mins, a private area and way to take this information down."
		case .checkboxes:
			return "You will need 5 mins, a private area and way to take this information down."
		case .seedPhrase:
			return "You will need 5 mins, a private area and way to take this information down."
		case .finished:
			return "You will need 5 mins, a private area and way to take this information down."
		}
	}

	var bullet2: String {
		switch self {
		case .intro:
			return "You will need 5 mins, a private area and way to take this information down."
		case .checkboxes:
			return "You will need 5 mins, a private area and way to take this information down."
		case .seedPhrase:
			return "You will need 5 mins, a private area and way to take this information down."
		case .finished:
			return "You will need 5 mins, a private area and way to take this information down."
		}
	}

	var bullet3: String {
		switch self {
		case .intro:
			return "You will need 5 mins, a private area and way to take this information down."
		case .checkboxes:
			return "You will need 5 mins, a private area and way to take this information down."
		case .seedPhrase:
			return "You will need 5 mins, a private area and way to take this information down."
		case .finished:
			return "You will need 5 mins, a private area and way to take this information down."
		}
	}
}
