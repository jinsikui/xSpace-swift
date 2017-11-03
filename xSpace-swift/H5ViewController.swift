//
//  H5ViewController.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/10.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

class H5ViewController: QtBaseViewController {
    
    var qtWebView: QtWebView!
    var url:String!
    
    init(url:String, title:String? = nil, showNavBar:Bool = true){
        super.init(nibName: nil, bundle: nil)
        self.url = url
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let qtWebView = QtWebView(frame: CGRect.zero)
        self.qtWebView = qtWebView
        self.view.addSubview(qtWebView)
        qtWebView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        //
        self.qtWebView.loadUrl(url: url)
    }
}


