//
//  QtSwitch.swift
//  xSpace-swift
//
//  Created by JSK on 2018/1/4.
//  Copyright © 2018年 JSK. All rights reserved.
//

import UIKit

class QtSwitch: UIControl {
    
    var onColor:UIColor = QtColor.green
    var onTitleColor:UIColor = QtColor.green
    var offColor:UIColor = QtColor.gray
    var offTitleColor:UIColor = QtColor.gray
    var outSize:CGSize = CGSize(width:52,height:26)
    var inSize:CGSize = CGSize(width:34,height:24)
    var title:String = ""
    var titleSize:CGFloat = 11
    var isOn:Bool = false
    var actionHandler:((Bool)->())? = nil
    
    var inView:UIView?
    var label:UILabel?
    
    init(_ outSize:CGSize = CGSize(width:52,height:26),
         inSize:CGSize = CGSize(width:34,height:24),
         onColor:UIColor = QtColor.fromRGB(0xFE6D4A),
         onTitleColor:UIColor = QtColor.fromRGB(0xFF5E38),
         offColor:UIColor = QtColor.fromRGB(0xE4E4E4),
         offTitleColor:UIColor = QtColor.fromRGB(0x777777),
         title:String = "",
         titleSize:CGFloat = 11,
         isInitOn:Bool = false,
         handler:((Bool)->())? = nil){
        super.init(frame: .zero)
        self.onColor = onColor
        self.onTitleColor = onTitleColor
        self.offColor = offColor
        self.offTitleColor = offTitleColor
        self.outSize = outSize
        self.inSize = inSize
        self.title = title
        self.titleSize = titleSize
        self.isOn = isInitOn
        self.actionHandler = handler
        
        //
        self.backgroundColor = self.isOn ? self.onColor : self.offColor
        self.layer.cornerRadius = self.outSize.height / 2
        //
        let inView = UIView()
        self.inView = inView
        inView.isUserInteractionEnabled = false
        inView.backgroundColor = QtColor.white
        inView.layer.cornerRadius = self.inSize.height / 2
        self.addSubview(inView)
        if(self.isOn){
            inView.snp.makeConstraints { (make) in
                make.right.equalTo(-(self.outSize.height - self.inSize.height)/2)
                make.top.equalTo((self.outSize.height - self.inSize.height)/2)
                make.width.equalTo(self.inSize.width)
                make.height.equalTo(self.inSize.height)
            }
        }
        else{
            inView.snp.makeConstraints { (make) in
                make.left.equalTo((self.outSize.height - self.inSize.height)/2)
                make.top.equalTo((self.outSize.height - self.inSize.height)/2)
                make.width.equalTo(self.inSize.width)
                make.height.equalTo(self.inSize.height)
            }
        }
        let label = QtViewFactory.label(font: QtFont.regularPF(self.titleSize), title: self.title, color: self.isOn ? self.onTitleColor : self.offTitleColor)
        self.label = label
        inView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        //
        self.addTarget(self, action: #selector(actionChange), for: .touchUpInside)
    }
    
    func actionChange(){
        self.isOn = !self.isOn
        if(self.isOn){
            self.inView!.snp.remakeConstraints { (make) in
                make.right.equalTo(-(self.outSize.height - self.inSize.height)/2)
                make.top.equalTo((self.outSize.height - self.inSize.height)/2)
                make.width.equalTo(self.inSize.width)
                make.height.equalTo(self.inSize.height)
            }
        }
        else{
            self.inView!.snp.remakeConstraints { (make) in
                make.left.equalTo((self.outSize.height - self.inSize.height)/2)
                make.top.equalTo((self.outSize.height - self.inSize.height)/2)
                make.width.equalTo(self.inSize.width)
                make.height.equalTo(self.inSize.height)
            }
        }
        UIView.animate(withDuration: 0.1) {
            self.backgroundColor = self.isOn ? self.onColor : self.offColor
            self.label!.textColor = self.isOn ? self.onTitleColor : self.offTitleColor
            self.layoutIfNeeded()
        }
        if let handler = self.actionHandler{
            handler(self.isOn)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
