import Foundation
import SafariServices
import SwiftUI
import UIKit
import WebKit
import FirebaseAnalytics

// inspired https://www.swiftyplace.com/blog/loading-a-web-view-in-swiftui-with-wkwebview

struct WebView: UIViewRepresentable {
    
    let url: URL
    
    @Binding
    var scrollToSignup: Bool
    
    @State
    private
    var didStartEditing: Bool = false
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "BitrefillHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
         
        let webview = EmbeddedWebView(frame: CGRect.zero, configuration: config, didStartEditing: $didStartEditing)
        webview.navigationDelegate = context.coordinator
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
    

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        
         
        // MARK: - WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
        
        // MARK: - WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "BitrefillHandler",
                  let bodyString = message.body as? String,
                  let data = bodyString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let invoiceId = json["invoiceId"] as? String,
                  let paymentUri = json["paymentUri"] as? String else { return }
            
            DispatchQueue.main.async {
                if (!invoiceId.isEmpty && !paymentUri.isEmpty) {
                    Analytics
                        .logEvent("user_shop_invoice_created",
                                  parameters: nil)
                }
            }
        }
    }
}
 

class EmbeddedWebView: WKWebView, WKNavigationDelegate {
    @Binding var didStartEditing: Bool
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, didStartEditing: Binding<Bool>) {
        _didStartEditing = didStartEditing
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
       
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        delay(2.5) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
    
    override var intrinsicContentSize: CGSize { scrollView.contentSize }
 
}
