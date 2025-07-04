import Combine
import Foundation
import SafariServices
import SwiftUI
import UIKit
import WebKit

struct SignupWebViewRepresentable: UIViewRepresentable {
	@Binding
	var userAction: Bool

	let urlString: String

	private var webView: WKWebView?

	init(userAction: Binding<Bool>, urlString: String) {
		webView = WKWebView()
		self.urlString = urlString
		_userAction = userAction
	}

	func makeUIView(context: Context) -> WKWebView {
		let source = "var meta = document.createElement('meta');" +
			"meta.name = 'viewport';" +
			"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
			"var head = document.getElementsByTagName('head')[0];" +
			"head.appendChild(meta);"

		let script = WKUserScript(source: source,
		                          injectionTime: .atDocumentEnd,
		                          forMainFrameOnly: true)

		let userContentController = WKUserContentController()
		userContentController.addUserScript(script)

		let configuration = WKWebViewConfiguration()
		configuration.userContentController = userContentController

		let _wkwebview = WKWebView(frame: .zero, configuration: configuration)
		_wkwebview.navigationDelegate = context.coordinator
		_wkwebview.uiDelegate = context.coordinator
		_wkwebview.allowsBackForwardNavigationGestures = false
		_wkwebview.scrollView.isScrollEnabled = false
        _wkwebview.backgroundColor = BrainwalletUIColor.surface

        var request = URLRequest(url: URL(string: urlString)!)

        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif

		_wkwebview.load(request)

		return _wkwebview
	}

	func updateUIView(_ webView: WKWebView, context _: Context) {
		webView.evaluateJavaScript("document.getElementById('submit-email').value") { response, _ in

			if let resultString = response as? String,
			   resultString.contains("Please") {
				userAction = true
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	class Coordinator: NSObject,
		WKNavigationDelegate,
		WKUIDelegate,
		WKScriptMessageHandler {
		func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
		}

		let parent: SignupWebViewRepresentable

		init(_ parent: SignupWebViewRepresentable) {
			self.parent = parent
		}
	}
}
