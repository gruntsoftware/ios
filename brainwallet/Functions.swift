import UIKit

func guardProtected(queue: DispatchQueue, callback: @escaping () -> Void) {
	DispatchQueue.main.async {
		if UIApplication.shared.isProtectedDataAvailable {
			callback()
		} else {
			var observer: Any?
			observer = NotificationCenter
				.default
				.addObserver(forName: UIApplication.protectedDataDidBecomeAvailableNotification,
				             object: nil,
				             queue: nil,
				             using: { _ in
				             	queue.async {
				             		callback()
				             	}
				             	if let observer = observer {
				             		NotificationCenter.default.removeObserver(observer)
				             	}
				             })
		}
	}
}

func strongify<Context: AnyObject>(_ context: Context, closure: @escaping (Context) -> Void) -> () -> Void {
	return { [weak context] in
		guard let strongContext = context else { return }
		closure(strongContext)
	}
}

func strongify<Context: AnyObject, Arguments>(_ context: Context?, closure: @escaping (Context, Arguments) -> Void) -> (Arguments) -> Void {
	return { [weak context] arguments in
		guard let strongContext = context else { return }
		closure(strongContext, arguments)
	}
}

let feeTiers: [(range: Range<UInt64>, fee: UInt64)] = [
    (0 ..< 1_398_000, 100_000),
    (1_398_000 ..< 6_991_000, 120_000),
    (6_991_000 ..< 27_965_000, 300_000),
    (27_965_000 ..< 139_820_000, 800_000),
    (139_820_000 ..< 279_653_600, 1_200_000),
    (279_653_600 ..< 699_220_000, 2_000_000),
    (699_220_000 ..< 1_398_440_000, 3_000_000),
    (1_398_440_000 ..< UInt64.max, 3_000_000) // Final open-ended range instead of default
]

/// Description: 1747735966
func tieredOpsFee(amount: UInt64) -> UInt64 {
    for tier in feeTiers {
        if tier.range.contains(amount) {
            return tier.fee
        }
    }
    return 3_000_000 // Fallback;
}
