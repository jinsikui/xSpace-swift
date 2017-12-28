//
//  QtSwift.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/23.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtSwift: NSObject {
    
    static func print(_ object:Any){
        #if DEBUG
            Swift.print("[\(Date())] \(object)")
        #endif
    }
    
}
