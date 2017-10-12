//
//  ViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/10.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import SwiftyJSON

class QTWebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let webview = QTWebView(frame:self.view.bounds)
        self.view.addSubview(webview)
        //webview.loadUrl(url: "https://m-staging.zhibo.qingting.fm/push-stream/3796a2a0ebcff2e2c206fd9a58a6922e?user_token=eyJhbGciOiJIUzI1NiJ9.Mzc5NmEyYTBlYmNmZjJlMmMyMDZmZDlhNThhNjkyMmU.X04V-Cfpj_dLWBG938suoCEo5BUjiV52MKZDdwBMDNM")
        guard let urlPath = Bundle.main.url(forResource: "Demo", withExtension: "html") else {
            print("Couldn't find the Demo.html file in bundle!")
            return
        }
        var urlString: String
        do {
            urlString  = try String(contentsOf: urlPath)
            webview.loadHTMLString(html:urlString)
            webview.registerNativeCallback(name: "getName", handler: { (any) -> Any? in
                return "JSK"
            })
            weak var weak = webview;
            webview.registerNativeCallback(name: "doSthAndCallJS", handler: { (any) -> Any? in
                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                    weak?.callNativeHandlerJSCallback(handlerName: "doSthAndCallJS", retValue: "Hellow world")
                })
                return nil
            })
        }
        catch let error as NSError {
            NSLog("\(error)")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

