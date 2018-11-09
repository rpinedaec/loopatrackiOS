//
// Copyright 2016 Anton Tananaev (anton.tananaev@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
