//
//  QtWebView.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/2.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import SnapKit
import PKHUD

class QtHandlerContext:NSObject{
    var handlerName: String?
    var nativeHandler: ((Any?)->Any?)?
    var jsCallbackName: String?
}

class QtWebView: UIView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var isFirstLoad = true
    var webView: WKWebView?
    var userContentController: WKUserContentController?
    var url:String?
    var html:String?
    //store the native handlers
    var handlerDic:Dictionary<String,QtHandlerContext>?
    static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(UIDevice.current.systemVersion) like Mac OS X)"
    var alwaysBounceVertical:Bool{
        set{
            webView!.scrollView.alwaysBounceVertical = newValue
        }
        get{
            return webView!.scrollView.alwaysBounceVertical
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }
    
    func prepare(){
        //
        self.userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = self.userContentController!
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        self.webView = webView
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.customUserAgent = QtWebView.userAgent
        self.addSubview(webView)
        webView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.left.right.equalTo(0)
        }
        //
        self.handlerDic = Dictionary<String, QtHandlerContext>()
    }
    
    func loadUrl(url:String){
        self.url = url
        let request = URLRequest(url: URL(string: self.url!)!)
        self.webView!.load(request)
    }
    
    func loadHTMLString(html:String){
        self.html = html
        self.webView!.loadHTMLString(html, baseURL: nil)
    }
    
    // 在loadUrl之前调用
    // js通过：window.webkit.messageHandlers[函数名].postMessage(paramsJSONObject)来调用，如果需要返回值paramsJSONObject需提供callback:'回调函数名'属性
    func registerNativeCallback(name:String, handler:@escaping (Any?)->Any?){
        self.userContentController!.add(self, name: name)
        let handlerContext = QtHandlerContext()
        handlerContext.handlerName = name
        handlerContext.nativeHandler = handler
        handlerContext.jsCallbackName = nil
        self.handlerDic![name] = handlerContext
    }
    
    //MARK: - WKScriptMessageHandler Protocol
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handlerName = message.name
        /*! @abstract The body of the message.
         @discussion Allowed types are NSNumber, NSString, NSDate, NSArray,
         NSDictionary, and NSNull.
         */
        let body = message.body
        let handlerContext = self.handlerDic![handlerName]
        if(handlerContext == nil){
            return;
        }
        //now handlerContext won't be nil
        if let bodyDic = body as? NSDictionary{
            let callbackName = bodyDic["callback"] as? String
            if(callbackName != nil && callbackName!.count > 0){
                handlerContext!.jsCallbackName = callbackName
            }
        }
        let nativeHandler = handlerContext!.nativeHandler!
        var retValue: Any?
        if(body is NSNull){
            retValue = nativeHandler(nil)
        }
        else{
            retValue = nativeHandler(body)
        }
        if(retValue != nil && handlerContext!.jsCallbackName != nil){
            self.callJS(funcName: handlerContext!.jsCallbackName!, params: retValue, resultHandler: nil)
        }
    }
    
    // 调用JS函数
    func callJS(funcName:String, params:Any?, resultHandler:((Any?) -> Swift.Void)?){
        var paramStr = ""
        if(params != nil){
            if let str = params as? String{
                paramStr = "\"" + str + "\""
            }
            else{
                paramStr = JSON(params!).description
            }
        }
        self.webView!.evaluateJavaScript("\(funcName)(\(paramStr))") { (any, error) in
            if(resultHandler != nil){
                resultHandler!(any)
            }
        }
    }
    
    // 调用之前JS传来的callback回调
    func callNativeHandlerJSCallback(handlerName:String, retValue:Any?){
        let handlerContext = self.handlerDic![handlerName]
        if(handlerContext == nil){
            return;
        }
        let jsCallbackName = handlerContext!.jsCallbackName
        if(jsCallbackName != nil){
            self.callJS(funcName: jsCallbackName!, params: retValue, resultHandler: nil)
        }
    }
    
    //MARK: - WKWebView Delegate
    
    // 发送请求之前，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    // 页面开始加载时
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        #if DEBUG
            print("load start")
        #endif
        if(isFirstLoad){
            isFirstLoad = false
            HUD.show(.progress)
        }
        //for ios 8
        webView.evaluateJavaScript("navigator.userAgent = '\(QtWebView.userAgent)'", completionHandler: nil)
    }
    
    // 页面加载失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
            print("load fail")
        #endif
        HUD.hide()
    }
    
    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
            print("load finish")
        #endif
        HUD.hide()
    }
}
