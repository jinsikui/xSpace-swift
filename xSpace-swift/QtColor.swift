//
//  QtColor.swift
//  LiveAssistant
//
//  Created by Yang Zheng on 06/04/2017.
//  Copyright © 2017 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtColor: UIColor {
    
    static func fromRGB(_ rgbValue: UInt) -> UIColor {
        return self.fromRGBA(rgbValue, alpha: 1)
    }
    
    static func fromRGBA(_ rgbValue: UInt, alpha: Float) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static func fromHexString(_ hexString:String) -> UIColor{
        return self.fromHexString(hexString, alpha:1.0)
    }
    
    static func fromHexString(_ hexString:String, alpha:CGFloat) -> UIColor{
        var str = hexString
        if(str[str.startIndex] == "#"){
            str = str[str.index(after: str.startIndex)..<str.endIndex]
        }
        // check for string length
        assert(6 == str.count || 3 == str.count);
        if(str.count == 3) {
            let s1 = str[str.startIndex]
            let s2 = str[str.index(str.startIndex, offsetBy: 1)]
            let s3 = str[str.index(str.startIndex, offsetBy: 2)]
            str = "\(s1)\(s1)\(s2)\(s2)\(s3)\(s3)"
        }
        
        let redHex = "0x\(str[str.startIndex..<str.index(str.startIndex, offsetBy:2)])"
        let redInt = Int(self.hexValueToUInt(redHex))
        let greenHex = "0x\(str[str.index(str.startIndex, offsetBy:2)..<str.index(str.startIndex, offsetBy:4)])"
        let greenInt = Int(self.hexValueToUInt(greenHex))
        let blueHex = "0x\(str[str.index(str.startIndex, offsetBy:4)..<str.endIndex])"
        let blueInt = Int(self.hexValueToUInt(blueHex))
        return self.from8Bit(red:redInt, green:greenInt, blue:blueInt, alpha:alpha)
    }
    
    static func from8Bit(red:Int, green:Int, blue:Int) -> UIColor{
        return self.from8Bit(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    static func from8Bit(red:Int, green:Int, blue:Int, alpha:CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
    
    static func hexValueToUInt(_ hexValue:String) -> UInt32{
        var value:UInt32 = 0
        let s = Scanner(string: hexValue)
        s.scanHexInt32(&value)
        return value
    }
}
