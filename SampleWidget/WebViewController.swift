//
//  WebViewController.swift
//  SampleWidget
//
//  Created by Noriyuki Yoshida on 2025/01/17.
//

import UIKit
import SwiftUI
import CoreLocation
@preconcurrency import WebKit

class ViewController: UIViewController, CLLocationManagerDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("aaaaaaaaaaaaa \(message)")
    }
    
    let js = """
navigator.geolocation.getCurrentPosition = function(success, error, options) {
    window.webkit.messageHandlers.locationHandler.postMessage("getCurrentPositionOverride"); // Send command
};
"""
    
    
    var webView: WKWebView!
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let preference = WKWebpagePreferences()
        preference.allowsContentJavaScript = true
        webConfiguration.defaultWebpagePreferences = preference
        
        let contentController = WKUserContentController()
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(script)
        contentController.add(self, name: "locationHandler")
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
//        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://kyome.io/debug/index.html")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを使用するためにdelegateをViewControllerクラスに設定する。
        locationManager.requestWhenInUseAuthorization() // 位置情報の許可設定を通知する。
        locationManager.requestLocation() // 1度だけ位置情報取得のリクエストを投げる。
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("location: \(location)") // CLLocationManagerクラスで取得した位置情報
            print("緯度: \(location.coordinate.latitude)")
            print("経度: \(location.coordinate.longitude)")
            switch locationManager.accuracyAuthorization {
            case .fullAccuracy:
                print("aaaaaaaaaaaaaa full")
            case .reducedAccuracy:
                print("aaaaaaaaaaaaaa reduced")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable{

    func makeUIViewController(context: Context) -> ViewController {
                // ビューコントローラーオブジェクトを作成し、その初期状態を設定します。
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
                // SwiftUI からの新しい情報で指定したビューコントローラの状態を更新
    }
}

extension ViewController: WKUIDelegate {
    // `alert` を表示する
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }

    // `confirm` を表示する
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }

    // `prompt` を表示する
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            completionHandler(alert.textFields?.first?.text)
        }))
        alert.addAction(.init(title: "キャンセル", style: .cancel, handler: { _ in
            completionHandler(nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("aaaaaaaaaaaaa")
        return .allow
    }
}
