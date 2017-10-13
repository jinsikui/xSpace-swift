//
//  ControllerManager.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/13.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import SwinjectStoryboard

class ControllerManager: NSObject {
    static let shared = ControllerManager()
    private let mainStoryboard = SwinjectStoryboard.create(name: "Main", bundle: nil, container: SwinjectStoryboard.defaultContainer)
    private let launchStoryboard = SwinjectStoryboard.create(name: "LaunchScreen", bundle: nil, container: SwinjectStoryboard.defaultContainer)
    
    func newViewController(prefix: String) -> UIViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: "\(prefix)ViewController")
    }
    
    func newNavigationController(prefix: String) -> UIViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: "\(prefix)NavigationController")
    }
    
    func getLaunchViewController() -> UIViewController {
        return launchStoryboard.instantiateViewController(withIdentifier: "LaunchViewController")
    }
}
