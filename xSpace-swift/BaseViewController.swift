//
//  BaseViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/24.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

extension UIViewController{
    
    @objc private func ex_viewWillAppear(_ animated: Bool) {
        print("in ex_viewWillAppear")
        self.ex_viewWillAppear(animated)
    }
    
    
    static func exchangeViewWillAppear() {
        // Inject "-pushViewController:animated:"
        DispatchQueue.once(token: "token", block: {
            let originalMethod = class_getInstanceMethod(self, #selector(viewWillAppear(_:)))
            let swizzledMethod = class_getInstanceMethod(self, #selector(ex_viewWillAppear(_:)))
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        })
    }
}

class BaseViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func prepare(){
        UIViewController.exchangeViewWillAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Base viewWillAppear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
