//
//  WebView.swift
//  DWFMS
//
//  Created by dwi on 2022/11/21.
//  Copyright © 2022 DWFMS. All rights reserved.
//

import Foundation
import WebKit

class WebViewInSwift: UIViewController, WKNavigationDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var webView: WKWebView?
        
        let configuration = WKWebViewConfiguration()
        

        
        webView = WKWebView (frame: self.view.frame, configuration: configuration)
        
        let url = URL(string: "https://ubistest.ubismaster.com:8047/")!
        webView!.loadFileURL(url, allowingReadAccessTo: url)
        
        // Create a WKWebView instance
        view.addSubview(webView!)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let url = URL(string: "https://ubistest.ubismaster.com:8047/")!
//        webView!.loadFileURL(url, allowingReadAccessTo: url)
    }

//    func callJSFunctionFromSwift(){
//        // 아래 패러미터 값 처리할 것
//        var scriptString = "setimge('resources/App_Company/UB000/AS_IMG/22100500173_1.jpg','1')"
//
//        // null 에러 나는 곳
//        webView!.evaluateJavaScript(scriptString, completionHandler: nil)
//
////        var appDelegate = AppDelegate()
////        appDelegate.main.setimage("resources/App_Company/UB000/AS_IMG/22100500173_1.jpg", num: 1)
//    }
    
}
