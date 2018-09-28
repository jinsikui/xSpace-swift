//
//  UITestController.swift
//  xSpace-swift
//
//  Created by JSK on 2018/1/4.
//  Copyright © 2018年 JSK. All rights reserved.
//

import UIKit
import MJRefresh
import KVOController
import Promises

class ViewModel:NSObject{
}

class UITestController: QtBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sw = QtSwitch(title:"公告")
        self.view.addSubview(sw)
        sw.snp.makeConstraints { (make) in
            make.left.top.equalTo(100)
            make.width.equalTo(sw.outSize.width)
            make.height.equalTo(sw.outSize.height)
        }
        sw.actionHandler = {(isOn) in
            print("===== isOn:\(isOn) =====")
        }
        
        let v = ObjcView(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
        self.view.addSubview(v);
    }
}
