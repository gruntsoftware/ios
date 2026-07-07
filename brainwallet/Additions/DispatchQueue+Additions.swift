import Foundation

extension DispatchQueue {
	static var walletQueue: DispatchQueue = .init(label: C.walletQueue)

	static let walletConcurrentQueue: DispatchQueue = .init(label: C.walletQueue, attributes: .concurrent)
    
    static var userInitQueue: DispatchQueue = .init(label: C.userInitQueue)

}
