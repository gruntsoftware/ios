import Foundation
import SwiftUI

class StartHostingController: UIHostingController<StartView> {
	// MARK: - Private

    var newMainViewModel: NewMainViewModel

	init(store: Store, walletManager: WalletManager) {
        newMainViewModel = NewMainViewModel(store: store, walletManager: walletManager)
        super.init(rootView: StartView(newMainViewModel: newMainViewModel))
	}
	// MARK: - Private

	@available(*, unavailable)
	@MainActor dynamic required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
