//
//  QtToast.swift
//  LiveAssistant
//
//  Created by JSK on 2017/12/30.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtToast: UIView {
    
    var label:UILabel?
    var font:UIFont = QtFont.regularPF(13)
    var boxColor:UIColor = QtColor.fromRGBA(0, alpha: 0.65)
    var boxCornerRadius:CGFloat = 6
    var margin:CGFloat = 10
    var maxWidth:CGFloat = QtDevice.screenWidth * 2 / 3
    var hideHandle:QtTaskHandle? = nil
    
    init(){
        super.init(frame: .zero)
        self.backgroundColor = self.boxColor
        self.layer.cornerRadius = self.boxCornerRadius
        let label = QtViewFactory.label(font: self.font, title: "", color: QtColor.white)
        self.label = label
        label.numberOfLines = 0
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ msg:String, duration:Float = 3, distanceToBottom:CGFloat = 250, inView:UIView? = nil){
        self.hide(animation: false)
        self.alpha = 1
        let labelSize = msg.qt_sizeWithFont(font, maxWidth: maxWidth - 2 * margin)
        let boxSize = CGSize(width:labelSize.width + 2 * margin, height:labelSize.height + 2 * margin)
        let parentView = inView == nil ? UIApplication.shared.delegate!.window!! : inView!
        self.label?.text = msg
        self.label?.snp.remakeConstraints({ (make) in
            make.left.top.equalTo(margin)
            make.width.equalTo(labelSize.width)
            make.height.equalTo(labelSize.height)
        })
        parentView.addSubview(self)
        self.snp.remakeConstraints { (make) in
            make.centerX.equalTo(parentView)
            make.width.equalTo(boxSize.width)
            make.height.equalTo(boxSize.height)
            make.bottom.equalTo(-distanceToBottom)
        }
        self.hideHandle = QtTask.asyncMain(after: .milliseconds(Int(duration*1000)), task: {[weak self] in
            self?.hide(animation: true)
        })
    }
    
    func hide(animation:Bool = true){
        if let hideHandle = self.hideHandle{
            hideHandle.cancel()
        }
        self._hide(animation:animation)
    }
    
    func _hide(animation:Bool){
        if(animation){
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }) { (success) in
                if(success){
                    self.removeFromSuperview()
                }
            }
        }
        else{
            self.removeFromSuperview()
            self.layer.removeAllAnimations()
        }
    }
    
    static var shared:QtToast = QtToast()
    
    static func show(_ msg:String, duration:Float = 3, distanceToBottom:CGFloat = 200, inView:UIView? = nil){
        QtToast.shared.show(msg, duration: duration, distanceToBottom: distanceToBottom, inView: inView)
    }
    
    static func hide(){
        QtToast.hide()
    }
}
