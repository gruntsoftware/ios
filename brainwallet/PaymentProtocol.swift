import BRCore
import Foundation

class PaymentProtocolDetails {
	let cPointer: UnsafeMutablePointer<BRPaymentProtocolDetails>
	var isManaged: Bool

	init(_ cPointer: UnsafeMutablePointer<BRPaymentProtocolDetails>) {
		self.cPointer = cPointer
		isManaged = false
	}

	init?(network: String = "main", outputs: [BRTxOutput], time: UInt64, expires: UInt64, memo: String? = nil,
	      paymentURL: String? = nil, merchantData: [UInt8]? = nil)
	{
		guard let cPointer = BRPaymentProtocolDetailsNew(network, outputs, outputs.count, time, expires, memo, paymentURL,
		                                             merchantData, merchantData?.count ?? 0) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	init?(bytes: [UInt8]) {
		guard let cPointer = BRPaymentProtocolDetailsParse(bytes, bytes.count) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	var bytes: [UInt8] {
		var bytes = [UInt8](repeating: 0, count: BRPaymentProtocolDetailsSerialize(cPointer, nil, 0))
		BRPaymentProtocolDetailsSerialize(cPointer, &bytes, bytes.count)
		return bytes
	}

	var network: String { // "main" or "test", default is "main"
		return String(cString: cPointer.pointee.network)
	}

	var outputs: [BRTxOutput] { // where to send payments, outputs[n].amount defaults to 0
		return [BRTxOutput](UnsafeBufferPointer(start: cPointer.pointee.outputs, count: cPointer.pointee.outCount))
	}

	var time: UInt64 { // request creation time, seconds since unix epoch, optional
		return cPointer.pointee.time
	}

	var expires: UInt64 { // when this request should be considered invalid, optional
		return cPointer.pointee.expires
	}

	var memo: String? { // human-readable description of request for the customer, optional
		guard cPointer.pointee.memo != nil else { return nil }
		return String(cString: cPointer.pointee.memo)
	}

	var paymentURL: String? { // url to send payment and get payment ack, optional
		guard cPointer.pointee.paymentURL != nil else { return nil }
		return String(cString: cPointer.pointee.paymentURL)
	}

	var merchantData: [UInt8]? { // arbitrary data to include in the payment message, optional
		guard cPointer.pointee.merchantData != nil else { return nil }
		return [UInt8](UnsafeBufferPointer(start: cPointer.pointee.merchantData, count: cPointer.pointee.merchDataLen))
	}

	deinit {
		if isManaged { BRPaymentProtocolDetailsFree(cPointer) }
	}
}

class PaymentProtocolRequest {
	let cPointer: UnsafeMutablePointer<BRPaymentProtocolRequest>
	var isManaged: Bool
	private var cName: String?
	private var errMsg: String?
	private var didValidate: Bool = false

	init(_ cPointer: UnsafeMutablePointer<BRPaymentProtocolRequest>) {
		self.cPointer = cPointer
		isManaged = false
	}

	init?(version: UInt32 = 1, pkiType: String = "none", pkiData: [UInt8]? = nil, details: PaymentProtocolDetails,
	      signature: [UInt8]? = nil)
	{
		guard details.isManaged else { return nil } // request must be able take over memory management of details
		guard let cPointer = BRPaymentProtocolRequestNew(version, pkiType, pkiData, pkiData?.count ?? 0, details.cPointer,
		                                             signature, signature?.count ?? 0) else { return nil }
		details.isManaged = false
		self.cPointer = cPointer
		isManaged = true
	}

	init?(data: Data) {
		let bytes = [UInt8](data)
		guard let cPointer = BRPaymentProtocolRequestParse(bytes, bytes.count) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	var bytes: [UInt8] {
		var bytes = [UInt8](repeating: 0, count: BRPaymentProtocolRequestSerialize(cPointer, nil, 0))
		BRPaymentProtocolRequestSerialize(cPointer, &bytes, bytes.count)
		return bytes
	}

	var version: UInt32 { // default is 1
		return cPointer.pointee.version
	}

	var pkiType: String { // none / x509+sha256 / x509+sha1, default is "none"
		return String(cString: cPointer.pointee.pkiType)
	}

	var pkiData: [UInt8]? { // depends on pkiType, optional
		guard cPointer.pointee.pkiData != nil else { return nil }
		return [UInt8](UnsafeBufferPointer(start: cPointer.pointee.pkiData, count: cPointer.pointee.pkiDataLen))
	}

	var details: PaymentProtocolDetails { // required
		return PaymentProtocolDetails(cPointer.pointee.details)
	}

	var signature: [UInt8]? { // pki-dependent signature, optional
		guard cPointer.pointee.signature != nil else { return nil }
		return [UInt8](UnsafeBufferPointer(start: cPointer.pointee.signature, count: cPointer.pointee.sigLen))
	}

	var certs: [[UInt8]] { // array of DER encoded certificates
		var certs = [[UInt8]]()
		var idx = 0

		while BRPaymentProtocolRequestCert(cPointer, nil, 0, idx) > 0 {
			certs.append([UInt8](repeating: 0, count: BRPaymentProtocolRequestCert(cPointer, nil, 0, idx)))
			BRPaymentProtocolRequestCert(cPointer, UnsafeMutablePointer(mutating: certs[idx]), certs[idx].count, idx)
			idx = idx + 1
		}

		return certs
	}

	var digest: [UInt8] { // hash of the request needed to sign or verify the request
		let digest = [UInt8](repeating: 0, count: BRPaymentProtocolRequestDigest(cPointer, nil, 0))
		BRPaymentProtocolRequestDigest(cPointer, UnsafeMutablePointer(mutating: digest), digest.count)
		return digest
	}

	func isValid() -> Bool {
		defer { didValidate = true }

		if pkiType != "none" {
			var certs = [SecCertificate]()
			let policies = [SecPolicy](repeating: SecPolicyCreateBasicX509(), count: 1)
			var trust: SecTrust?
			var trustResult = SecTrustResultType.invalid

			for c in self.certs {
				if let cert = SecCertificateCreateWithData(nil, Data(bytes: c) as CFData) { certs.append(cert) }
			}

			if !certs.isEmpty {
				cName = SecCertificateCopySubjectSummary(certs[0]) as String?
			}

			SecTrustCreateWithCertificates(certs as CFTypeRef, policies as CFTypeRef, &trust)
			if let trust = trust { SecTrustEvaluate(trust, &trustResult) } // verify certificate chain

			// .unspecified indicates a positive result that wasn't decided by the user
			guard trustResult == .unspecified || trustResult == .proceed
			else {
				errMsg = certs.count > 0 ? "S.PaymentProtocol.Errors.untrustedCertificate"  : "S.PaymentProtocol.Errors.missingCertificate"

				if let trust = trust, let properties = SecTrustCopyProperties(trust) {
					for prop in properties as! [[AnyHashable: Any]] {
						if prop["type"] as? String != kSecPropertyTypeError as String { continue }
						errMsg = errMsg! + " - " + (prop["value"] as! String)
						break
					}
				}

				return false
			}

			var status = errSecUnimplemented
			var pubKey: SecKey?
			if let trust = trust { pubKey = SecTrustCopyPublicKey(trust) }

			if let pubKey = pubKey, let signature = signature {
				if pkiType == "x509+sha256" {
					status = SecKeyRawVerify(pubKey, .PKCS1SHA256, digest, digest.count, signature, signature.count)
				} else if pkiType == "x509+sha1" {
					status = SecKeyRawVerify(pubKey, .PKCS1SHA1, digest, digest.count, signature, signature.count)
				}
			}

			guard status == errSecSuccess
			else {
				if status == errSecUnimplemented {
					errMsg = "S.PaymentProtocol.Errors.unsupportedSignatureType"
					print(errMsg!)
				} else {
					errMsg = NSError(domain: NSOSStatusErrorDomain, code: Int(status)).localizedDescription
					print("SecKeyRawVerify error: " + errMsg!)
				}

				return false
			}
		} else if !certs.isEmpty { // non-standard extention to include an un-certified request name
			cName = String(data: Data(certs[0]), encoding: .utf8)
		}

		guard details.expires == 0 || NSDate.timeIntervalSinceReferenceDate <= Double(details.expires)
		else {
			errMsg = "request expired" 
			return false
		}

		return true
	}

	var commonName: String? {
		if !didValidate { _ = isValid() }
		return cName
	}

	var errorMessage: String? {
		if !didValidate { _ = isValid() }
		return errMsg
	}

	deinit {
		if isManaged { BRPaymentProtocolRequestFree(cPointer) }
	}
}

class PaymentProtocolPayment {
	let cPointer: UnsafeMutablePointer<BRPaymentProtocolPayment>
	var isManaged: Bool

	init(_ cPointer: UnsafeMutablePointer<BRPaymentProtocolPayment>) {
		self.cPointer = cPointer
		isManaged = false
	}

	init?(merchantData: [UInt8]? = nil, transactions: [BRTxRef?], refundTo: [(address: String, amount: UInt64)],
	      memo: String? = nil)
	{
		var txRefs = transactions
		guard let cPointer = BRPaymentProtocolPaymentNew(merchantData, merchantData?.count ?? 0, &txRefs, txRefs.count,
		                                             refundTo.map { $0.amount },
		                                             refundTo.map { BRAddress(string: $0.address) ?? BRAddress() },
		                                             refundTo.count, memo) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	init?(bytes: [UInt8]) {
		guard let cPointer = BRPaymentProtocolPaymentParse(bytes, bytes.count) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	var bytes: [UInt8] {
		var bytes = [UInt8](repeating: 0, count: BRPaymentProtocolPaymentSerialize(cPointer, nil, 0))
		BRPaymentProtocolPaymentSerialize(cPointer, &bytes, bytes.count)
		return bytes
	}

	var merchantData: [UInt8]? { // from request->details->merchantData, optional
		guard cPointer.pointee.merchantData != nil else { return nil }
		return [UInt8](UnsafeBufferPointer(start: cPointer.pointee.merchantData, count: cPointer.pointee.merchDataLen))
	}

	var transactions: [BRTxRef?] { // array of signed BRTxRef to satisfy outputs from details
		return [BRTxRef?](UnsafeBufferPointer(start: cPointer.pointee.transactions, count: cPointer.pointee.txCount))
	}

	var refundTo: [BRTxOutput] { // where to send refunds, if a refund is necessary, refundTo[n].amount defaults to 0
		return [BRTxOutput](UnsafeBufferPointer(start: cPointer.pointee.refundTo, count: cPointer.pointee.refundToCount))
	}

	var memo: String? { // human-readable message for the merchant, optional
		guard cPointer.pointee.memo != nil else { return nil }
		return String(cString: cPointer.pointee.memo)
	}

	deinit {
		if isManaged { BRPaymentProtocolPaymentFree(cPointer) }
	}
}

class PaymentProtocolACK {
	let cPointer: UnsafeMutablePointer<BRPaymentProtocolACK>
	var isManaged: Bool

	init(_ cPointer: UnsafeMutablePointer<BRPaymentProtocolACK>) {
		self.cPointer = cPointer
		isManaged = false
	}

	init?(payment: PaymentProtocolPayment, memo: String? = nil) {
		guard payment.isManaged else { return nil } // ack must be able to take over memory management of payment
		guard let cPointer = BRPaymentProtocolACKNew(payment.cPointer, memo) else { return nil }
		payment.isManaged = false
		self.cPointer = cPointer
		isManaged = true
	}

	init?(data: Data) {
		let bytes = [UInt8](data)
		guard let cPointer = BRPaymentProtocolACKParse(bytes, bytes.count) else { return nil }
		self.cPointer = cPointer
		isManaged = true
	}

	var bytes: [UInt8] {
		var bytes = [UInt8](repeating: 0, count: BRPaymentProtocolACKSerialize(cPointer, nil, 0))
		BRPaymentProtocolACKSerialize(cPointer, &bytes, bytes.count)
		return bytes
	}

	var payment: PaymentProtocolPayment { // payment message that triggered this ack, required
		return PaymentProtocolPayment(cPointer.pointee.payment)
	}

	var memo: String? { // human-readable message for customer, optional
		guard cPointer.pointee.memo != nil else { return nil }
		return String(cString: cPointer.pointee.memo)
	}

	deinit {
		if isManaged { BRPaymentProtocolACKFree(cPointer) }
	}
}
