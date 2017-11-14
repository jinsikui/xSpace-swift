//
//  NoticeController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/4.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class NoticeController: QtBaseViewController {
    
    let myCustomEventName = "myCustomEventName"
    let myCustomUserInfoKey = "myCustomUserInfoKey"
    var life:NSObject? = NSObject()
    var myTimer:QtTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "test notice and timer"
        QtNotice.shared.registerSignIn(lifeIndicator: self) {[unowned self] (any) in
            self.fireSignIn()
        }
        
        QtNotice.shared.registerEvent(self.myCustomEventName, lifeIndicator: life!) {[unowned self] (any) in
            let dic = any as! Dictionary<String, Any>
            print("====== \(dic[self.myCustomUserInfoKey] as! String) ======")
        }
        
        myTimer = QtTimer(interval: .seconds(2), action: {[unowned self] in
            self.fireQtTimer()
        })
        
        let btn = QtViewFactory.button(text: "start", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionNotice), for: .touchUpInside)
        btn.frame = CGRect(x: 0.5*(QtDevice.screenWidth - 150), y: 100, width: 150, height: 50)
        self.view.addSubview(btn)
    }
    
    deinit{
        print("===== NoticeController deinit =====")
    }
    
    func fireSignIn(){
        print("===== fire sign in =====")
    }
    
    func fireQtTimer(){
        print("===== fire qt timer =====")
    }
    
    func fireNoticeTimer(){
        print("===== fire notice timer =====")
    }
    
    @objc func actionNotice(){
        QtNotice.shared.postSignIn()
        DispatchQueue.global().async {
            for i in 1...10000{
                QtNotice.shared.postEvent(self.myCustomEventName, userInfo: [self.myCustomUserInfoKey:"hello custom event \(i)"])
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+DispatchTimeInterval.seconds(1)) {
            self.life = nil // 停止接收customEvent
        }
        QtNotice.shared.registerTimer(lifeIndicator: self, interval: 3) {[unowned self] in
            self.fireNoticeTimer()
        }
        myTimer!.start()
    }
}
