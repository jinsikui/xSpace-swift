//
//  QtAlert.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/17.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtAlertRootController:UIViewController{
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIApplication.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool{
        return UIApplication.shared.isStatusBarHidden
    }
}

enum QtAlertAction{
    case cancel
    case confirm
}

class QtAlert: NSObject {
    
    static var alertWindow:UIWindow?
    static var isShowing:Bool = false
    static var lastMessage:String?
    
    static func show(message:String){
        self.show(title: "提示", message: message, cancelTitle: "确定", confirmTitle: nil, completion: nil)
    }
    
    static func show(message:String, completion:((QtAlertAction)->())?){
        self.show(title: "提示", message: message, cancelTitle: "确定", confirmTitle: nil, completion: completion)
    }
    
    static func show(title:String?, message:String?, cancelTitle:String?, confirmTitle:String?, completion:((QtAlertAction)->())?){
        if(isShowing && lastMessage != nil && message != nil && lastMessage! == message!){
            return
        }
        isShowing = true
        lastMessage = message
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if(cancelTitle != nil && cancelTitle!.characters.count > 0){
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                QtAlert.isShowing = false
                if(completion != nil){
                    completion!(.cancel)
                }
                releaseWindow()
            })
            alert.addAction(cancelAction)
        }
        if(confirmTitle != nil && confirmTitle!.characters.count > 0){
            let confirmAction = UIAlertAction(title: confirmTitle, style: .default, handler: { (action) in
                QtAlert.isShowing = false
                if(completion != nil){
                    completion!(.confirm)
                }
                releaseWindow()
            })
            alert.addAction(confirmAction)
        }
        //
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let window = alertWindow!
        window.rootViewController = QtAlertRootController()
        window.windowLevel = UIWindowLevelAlert;
        window.makeKeyAndVisible()
        window.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    static func releaseWindow(){
        QtAlert.alertWindow!.resignKey()
        QtAlert.alertWindow?.isHidden = true;
        QtAlert.alertWindow = nil;
    }
}





