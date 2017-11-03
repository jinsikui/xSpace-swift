//
//  QtViewFactory.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/16.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtViewFactory: NSObject {
    static func label(font:UIFont, title:String?, color:UIColor, alignment:NSTextAlignment = .center) -> UILabel{
        let label = UILabel()
        label.text = title
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        return label
    }
    
    static func imageButton(image:UIImage) -> UIButton{
        let button = UIButton()
        button.setImage(image, for: .normal)
        return button
    }
    
    static func imageButton(imageName:String) -> UIButton{
        let button = UIButton()
        let image = UIImage(named:imageName)
        button.setImage(image, for: .normal)
        return button
    }
    
    static func imageButton(imageName:String, width:inout CGFloat, height:inout CGFloat) -> UIButton{
        let button = UIButton()
        let image = UIImage(named:imageName)
        width = image!.size.width
        height = image!.size.height
        button.setImage(image, for: .normal)
        return button
    }
    
    static func button(text:String, font:UIFont, textColor:UIColor, bgColor:UIColor = QtColor.white, cornerRadius:CGFloat = 0, borderColor:UIColor = QtColor.clear, borderWidth:CGFloat = 0.5) -> UIButton{
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel!.font = font
        button.backgroundColor = bgColor
        if(cornerRadius > 0){
            button.layer.cornerRadius = cornerRadius
        }
        if(!borderColor.isEqual(QtColor.clear)){
            button.layer.borderWidth = borderWidth
            button.layer.borderColor = borderColor.cgColor
        }
        return button
    }
}
