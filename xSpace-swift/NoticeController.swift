//
//  NoticeController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/4.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class NoticeController: QtBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "test notice and timer"
        QtNotice.shared.registerSignIn(lifeIndicator: self) {[weak self] (any) in
            self?.fireSignIn()
        }
        
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
    
    func fireTimer(){
        print("===== fire timer =====")
    }
    
    @objc func actionNotice(){
        QtNotice.shared.postSignIn()
        QtNotice.shared.registerTimer(lifeIndicator: self, interval: 3) {[weak self] in
            self?.fireTimer()
        }
    }
}
