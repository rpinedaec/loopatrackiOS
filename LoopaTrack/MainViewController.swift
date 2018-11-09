import UIKit
import WebKit

class MainViewController: UIViewController, WKUIDelegate {
    
    static let eventLogin = Notification.Name("eventLogin")
    static let eventToken = Notification.Name("eventToken")
    static let keyToken = "keyToken"
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusFrame = UIApplication.shared.statusBarFrame
        var viewFrame = view.frame
        viewFrame.origin.y = statusFrame.size.height
        viewFrame.size.height -= statusFrame.size.height
        
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "appInterface")

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        
        webView = WKWebView(frame: viewFrame, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(webView)
        
        if let url = URL(string: UserDefaults.standard.object(forKey: "url") as! String) {
            self.webView.load(URLRequest(url: url))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceive(_:)), name: MainViewController.eventToken, object: nil)
    }
    
    @objc func onReceive(_ notification:Notification) {
        if let token = notification.userInfo?[MainViewController.keyToken] {
            let code = "updateNotificationToken && updateNotificationToken('\(token)')"
            webView.evaluateJavaScript(code, completionHandler: nil)
        }
    }

}

extension MainViewController : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? String {
            if body.contains("login") {
                NotificationCenter.default.post(name: MainViewController.eventLogin, object: nil)
            }
        }
    }
    
}
