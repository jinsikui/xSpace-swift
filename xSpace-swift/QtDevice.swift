//
//  QtScreen.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/17.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtDevice: NSObject {
    
    static var appVersion:String{
        get{
            return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        }
    }
    
    static var screenWidth:CGFloat{
        get{
            return UIScreen.main.bounds.width
        }
    }
    
    static var screenHeight:CGFloat{
        get{
            return UIScreen.main.bounds.height
        }
    }
    
    static var statusBarHeight:CGFloat{
        get{
            if(self.isIphoneX){
                return 44
            }
            return 20
        }
    }
    
    static var navBarHeight:CGFloat{
        get{
            return 44
        }
    }
    
    static var bottomBarHeight:CGFloat{
        if(self.isIphoneX){
            return 34
        }
        return 0
    }
    
    static var iosVersion:Float{
        get{
            let str = UIDevice.current.systemVersion
            //convert like "10.3.1" -> "10.3"
            let _str:String?
            let indexes = str.indexes(of: ".")
            if(indexes.count >= 2){
                let dot2Index = indexes[1]
                _str = String(str[str.startIndex..<dot2Index])
            }
            else{
                _str = str
            }
            return Float(_str!)!
        }
    }
    
    static var deviceId:String?{
        get{
            return UIDevice.current.identifierForVendor!.uuidString
        }
    }
    
    static var iosRawVersion:String{
        get{
            return UIDevice.current.systemVersion
        }
    }
    
    static var deviceModel:String{
        get{
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
    
    static var isIphoneX:Bool{
        get{
            return QtDevice.screenWidth == 375 && QtDevice.screenHeight == 812
        }
    }
}
