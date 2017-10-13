//
//  ViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/10.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import SwiftyJSON


class QTWebViewController: QTBaseViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }
    
    func prepare(){
        super.showNavBar = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let webview = QTWebView(frame:self.view.bounds)
        self.view.addSubview(webview)
        //
        guard let urlPath = Bundle.main.url(forResource: "Demo", withExtension: "html") else {
            print("Couldn't find the Demo.html file in bundle!")
            return
        }
        var urlString: String
        do {
            urlString  = try String(contentsOf: urlPath)
            webview.loadHTMLString(html:urlString)
            webview.registerNativeCallback(name: "getName", handler: { (any) -> Any? in
                let nickname:String? = nil
                let name = "JSK"
                return ["name":name, "nickname":nickname]
            })
            weak var weak = webview;
            webview.registerNativeCallback(name: "doSthAndCallJS", handler: { (any) -> Any? in
                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                    weak?.callNativeHandlerJSCallback(handlerName: "doSthAndCallJS", retValue: "Hellow world")
                })
                return nil
            })
            webview.registerNativeCallback(name: "goToH5", handler: { (params) -> Any? in
                guard let paramDic = params as? NSDictionary else{
                    return nil
                }
                guard let url = paramDic["url"] as? String else{
                    return nil
                }
                let title = paramDic["title"] as? String
                let h5Controller = H5ViewController(url: url, title:title)
                self.navigationController?.pushViewController(h5Controller, animated: true)
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

