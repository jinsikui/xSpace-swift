//
//  AViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/24.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class AViewController: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("A viewWillAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
