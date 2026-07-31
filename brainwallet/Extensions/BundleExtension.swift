import Foundation

// Intentionally empty. This used to hold a Bundle.setLanguage(_:) mechanism
// that swapped Bundle.main's class at runtime to pin localizedString(forKey:)
// to a specific .lproj bundle, overriding iOS's automatic language resolution.
// Removed so the String Catalog's automatic preferredLanguage resolution is
// the only mechanism in play. See issue #135 for the related, still-orphaned
// in-app language picker this used to back.
