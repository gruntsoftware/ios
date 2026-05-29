import Foundation
import SafariServices
import SwiftUI
import UIKit
import WebKit

// inspired https://www.swiftyplace.com/blog/loading-a-web-view-in-swiftui-with-wkwebview

struct WebView: UIViewRepresentable {
	let url: URL
    
	@Binding
	var scrollToSignup: Bool

	@State
	private
	var didStartEditing: Bool = false

	func makeUIView(context _: Context) -> WKWebView {
		let webview = SignupWebView(frame: CGRect.zero, didStartEditing: $didStartEditing)
        var request = URLRequest(url: url)
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
		webview.load(request)
		return webview
	}

	func updateUIView(_ webview: WKWebView, context _: Context) {

		webview.endEditing(true)
		if scrollToSignup {
			let point = CGPoint(x: 0, y: webview.scrollView.contentSize.height - webview.frame.size.height / 2)

			webview.scrollView.setContentOffset(point, animated: true)
			DispatchQueue.main.async {
				self.scrollToSignup = false
			}
		}
	}
}

// https://stackoverflow.com/questions/44684714/show-keyboard-on-button-click-by-calling-wkwebview-input-field
class SignupWebView: WKWebView, WKNavigationDelegate {
	@Binding
	var didStartEditing: Bool

    let activityIndicator = UIActivityIndicatorView(style: .large)

	init(frame: CGRect, didStartEditing: Binding<Bool>) {
		_didStartEditing = didStartEditing

		let configuration = WKWebViewConfiguration()
		super.init(frame: frame, configuration: configuration)
		navigationDelegate = self
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: self.bounds.center.x - 40, y: self.bounds.center.y - 40, width: 80, height: 80)
        self.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var intrinsicContentSize: CGSize {
		return scrollView.contentSize
	}

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()
        
        // Inject viewport meta
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='width=device-width';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
        
        // Inject postMessage listener
        let messageScript = """
            (function() {
                function handleMessage(event) {
                    try {
                        var data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                        if (data && data.event === 'invoice_created') {
                            window.webkit.messageHandlers.BitrefillHandler.postMessage(JSON.stringify(data));
                        }
                    } catch(e) {
                        console.log('parse error:', e);
                    }
                }
                window.addEventListener('message', handleMessage);
                document.addEventListener('message', handleMessage);
            })();
        """
        webView.evaluateJavaScript(messageScript, completionHandler: nil)
    }
    
     
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       activityIndicator.stopAnimating()
    }
}
