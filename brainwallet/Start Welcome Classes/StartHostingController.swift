import Foundation
import SwiftUI

class StartHostingController: UIHostingController<StartView> {
	// MARK: - Private

	var startViewModel: StartViewModel

	init(store: Store, walletManager: WalletManager) {
        startViewModel = StartViewModel(store: store)
        
        let newMainViewModel = NewMainViewModel(store: store, walletManager: walletManager)
        super.init(rootView: StartView(startViewModel: startViewModel, newMainViewModel: newMainViewModel))
	}
	// MARK: - Private

	@available(*, unavailable)
	@MainActor dynamic required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
