//
//  AnimationsController.swift
//  xSpace-swift
//
//  Created by JSK on 2018/8/16.
//  Copyright © 2018年 JSK. All rights reserved.
//

import UIKit
import SnapKit

class AnimationsController: QtBaseViewController {
    var avatar:UIView?
    var avatarWidth:CGFloat = 80
    var ringLayer:CAShapeLayer?
    var ringWidth:CGFloat = 2
    var ringAniLayer:CAShapeLayer?
    var ringAniWidth:CGFloat = 5
    var isAnimating:Bool = false
    var animationKey:String = "talkingAnimation"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Animations"
        self.view.backgroundColor = QtColor.fromRGB(0x232C4B)
        
        let circle = UIView()
        self.avatar = circle
        circle.layer.cornerRadius = avatarWidth/2
        circle.backgroundColor = QtColor.fromRGB(0x046501)
        circle.clipsToBounds = false
        self.view.addSubview(circle)
        circle.snp.makeConstraints { (make) in
            make.width.height.equalTo(avatarWidth)
            make.centerX.equalTo(self.view)
            make.top.equalTo(50)
        }
        let g = UITapGestureRecognizer(target: self, action: #selector(actionRefresh))
        circle.isUserInteractionEnabled = true
        circle.addGestureRecognizer(g)
    }
    
    func startAnimation(){
        if(isAnimating){
            return
        }
        isAnimating = true
        
        let ringLayer = CAShapeLayer()
        self.ringLayer = ringLayer
        ringLayer.path = UIBezierPath(ovalIn: CGRect(x: -ringWidth/2, y: -ringWidth/2, width: avatarWidth+ringWidth, height: avatarWidth+ringWidth)).cgPath
        ringLayer.lineWidth = ringWidth
        ringLayer.strokeColor = QtColor.fromRGB(0x90B1FF).cgColor;
        ringLayer.fillColor = UIColor.clear.cgColor;
        self.avatar?.layer.addSublayer(ringLayer)
        
        let ringAniLayer = CAShapeLayer()
        self.ringAniLayer = ringAniLayer
        ringAniLayer.path = UIBezierPath(ovalIn: CGRect(x: -ringWidth-ringAniWidth/2, y: -ringWidth-ringAniWidth/2, width: avatarWidth+ringWidth*2+ringAniWidth, height: avatarWidth+ringWidth*2+ringAniWidth)).cgPath
        ringAniLayer.lineWidth = ringAniWidth
        ringAniLayer.strokeColor = QtColor.fromRGBA(0x8FBDFF, alpha: 0.3).cgColor
        ringAniLayer.fillColor = UIColor.clear.cgColor;
        self.avatar?.layer.addSublayer(ringAniLayer)

        let animation = CABasicAnimation(keyPath: "strokeColor")
        // 设定动画选项
        animation.duration = 0.5 // 持续时间
        animation.repeatCount = .infinity // 重复次数(如果设成.infinity一直重复下去)
        animation.autoreverses = true
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear) // 随时间线性变化
        // 设置边界值
        animation.fromValue = QtColor.fromRGBA(0x8FBDFF, alpha: 0.3).cgColor  //起始
        animation.toValue = QtColor.fromRGBA(0x8FBDFF, alpha: 0.02).cgColor   //终止
        // 添加动画
        ringAniLayer.add(animation, forKey: self.animationKey)
    }
    
    func stopAnimation(){
        if(!isAnimating){
            return
        }
        isAnimating = false
        if let ringLayer = self.ringLayer, let ringAniLayer = self.ringAniLayer{
            ringLayer.removeFromSuperlayer()
            ringAniLayer.removeFromSuperlayer()
            ringAniLayer.removeAnimation(forKey: self.animationKey)
        }
        
    }
    
    func actionRefresh(){
        //模拟refresh
        if(self.avatarWidth == 80){
            self.stopAnimation()
            self.avatarWidth = 50
            self.avatar?.layer.cornerRadius = self.avatarWidth / 2
            self.avatar?.snp.remakeConstraints({ (make) in
                make.width.height.equalTo(avatarWidth)
                make.centerX.equalTo(self.view)
                make.top.equalTo(50)
            })
            self.startAnimation()
        }
        else{
            self.stopAnimation()
            self.avatarWidth = 80
            self.avatar?.layer.cornerRadius = self.avatarWidth / 2
            self.avatar?.snp.remakeConstraints({ (make) in
                make.width.height.equalTo(avatarWidth)
                make.centerX.equalTo(self.view)
                make.top.equalTo(50)
            })
            self.startAnimation()
        }
    }
}
