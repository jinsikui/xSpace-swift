//
//  QtFont.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/17.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtFont: NSObject {
    
    private static var _systemVersion:Float?
    
    static var systemVersion:Float{
        get{
            if(_systemVersion == nil){
                _systemVersion = QtDevice.iosVersion
            }
            return _systemVersion!
        }
    }
    /*
     *  中文字体
     */
    static func lightPF(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont(name: "PingFangSC-Light", size: size)!
        }
        else if(systemVersion >= 8.19 ){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
        }
        else{
            return UIFont(name:"HelveticaNeue-Ligh", size:size)!
        }
    }
    
    static func regularPF(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont(name: "PingFangSC-Regular", size: size)!
        }
        else if(systemVersion >= 8.19 ){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
        }
        else{
            return UIFont(name:"HelveticaNeue", size:size)!
        }
    }
    
    static func mediumPF(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont(name: "PingFangSC-Medium", size: size)!
        }
        else if(systemVersion >= 8.19 ){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightMedium)
        }
        else{
            return UIFont(name:"HelveticaNeue-Medium", size:size)!
        }
    }
    
    static func semiboldPF(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont(name: "PingFangSC-Semibold", size: size)!
        }
        else if(systemVersion >= 8.19 ){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
        }
        else{
            return UIFont(name:"HelveticaNeue-Bold", size:size)!
        }
    }
    
    /*
     *  英文和数字字体
     */
    static func bold(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightMedium)
        }
        else{
            return UIFont(name:"HelveticaNeue-Medium", size:size)!
        }
    }
    
    static func regular(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
        }
        else{
            return UIFont(name:"HelveticaNeue-Light", size:size)!
        }
    }
    
    static func light(_ size:CGFloat) -> UIFont{
        if(systemVersion >= 9.0){
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
        }
        else{
            return UIFont(name:"HelveticaNeue-Thin", size:size)!
        }
    }
}
