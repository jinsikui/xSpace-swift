//
//  TestLiveCycleController.swift
//  xSpace-swift
//
//  Created by JSK on 2018/1/25.
//  Copyright © 2018年 JSK. All rights reserved.
//

import UIKit

class TestLiveCycleController: QtBaseViewController {
    
    init(){
        print("===== TestLiveCycleController init =====")
        super.init(nibName: nil, bundle: nil)
        self.initViews()
        print("===== TestLiveCycleController init-end =====")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("===== viewDidLoad =====")
        super.viewDidLoad()
        self.initViews()
        print("===== viewDidLoad-end =====")
    }

    func initViews(){
        let callId:String = "\(arc4random())"
        print("===== initViews \(callId)=====")
        if self.view.qt_initialized { // should trigger viewDidLoad on first call
            print("===== initViews-end \(callId) already initialized =====")
            return
        }
        //imagine add views...
        
        self.view.qt_initialized = true
        print("===== initViews-end \(callId)=====")
    }

}
