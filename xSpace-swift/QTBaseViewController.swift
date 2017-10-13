//
//  QTBaseViewController.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/13.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QTBaseViewController: UIViewController {
    
    var showNavBar:Bool = true

    override func viewWillAppear(_ animated: Bool) {
        if(self.navigationController != nil){
            self.navigationController!.isNavigationBarHidden = !self.showNavBar
        }
    }

}
