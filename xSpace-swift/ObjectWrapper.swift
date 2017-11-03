//
//  ObjectWrapper.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/3.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class ObjectWrapper<T> {
    let value :T
    
    init?(value:T){
        self.value = value
    }
}
