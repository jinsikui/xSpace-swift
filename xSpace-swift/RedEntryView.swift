//
//  RedPromptView.swift
//  LiveAssistant
//
//  Created by JSK on 2018/1/18.
//  Copyright © 2018年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class RedEntryView: UIView {
    
    var imgView:UIImageView!
    var numView:UIView!
    var numLabel:UILabel!
    
    private var _count:Int = 1
    var count:Int{
        get{
            return _count
        }
        set{
            if Thread.isMainThread {
                self.updateCount(newValue)
            }
            else{
                QtTask.asyncMain {[weak self] in
                    self?.updateCount(newValue)
                }
            }
        }
    }
    var timer:QtTimer!
    var shakeIntervalSeconds:Int = 30
    var animationKey = "shakeAnimation"
    
    init(count:Int){
        super.init(frame:.zero)
        self.initViews()
        self.count = count
        self.timer = QtTimer(interval: .seconds(shakeIntervalSeconds), queue: DispatchQueue.main, action: {[weak self] in
            self?.shake()
        })
        self.timer.start()
    }
    
    deinit {
        self.removeShake()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews(){
        //
        self.backgroundColor = QtColor.clear
        self.clipsToBounds = false
        //
        let img = UIImage(named:"redPacketEntry")
        let imgView = UIImageView(image:img)
        self.imgView = imgView
        self.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.width.equalTo(img!.size.width)
            make.height.equalTo(img!.size.height)
        }
        //
        numView = UIView()
        numView.backgroundColor = QtColor.white
        numView.layer.cornerRadius = 8.5
        numView.layer.borderColor = QtColor.fromRGB(0xE5241D).cgColor
        numView.layer.borderWidth = 1
        imgView.addSubview(numView)
        imgView.clipsToBounds = false
        numView.snp.makeConstraints { (make) in
            make.right.equalTo(imgView.snp.right).offset(4)
            make.top.equalTo(imgView.snp.top).offset(25)
            make.width.equalTo(17)
            make.height.equalTo(17)
        }
        //
        numLabel = QtViewFactory.label(font: QtFont.mediumPF(12), title: "", color: QtColor.fromRGB(0xFF3A39))
        numView.addSubview(numLabel)
        numLabel.snp.makeConstraints { (make) in
            make.center.equalTo(numView)
        }
    }
    
    func updateCount(_ count:Int){
        _count = count
        //
        if _count <= 1{
            numView.isHidden = true
        }
        else{
            numView.isHidden = false
            let text = _count > 9 ? "9+" : "\(_count)"
            numLabel.text = text
        }
    }
    
    func shake(){
        self.removeShake()
        // 指定Z轴的话，就和UIView的动画一样绕中心旋转
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        // 设定动画选项
        animation.duration = 0.05 // 持续时间
        animation.repeatCount = 5 // 重复次数(如果设成.infinity一直重复下去)
        animation.autoreverses = true
        // 设定旋转角度
        animation.fromValue = NSNumber(value: (-10.0 / 180.0 * Double.pi))  //起始角度
        animation.toValue = NSNumber(value: (10.0 / 180.0 * Double.pi))   //终止角度
        // 添加动画
        imgView.layer.add(animation, forKey: animationKey)
        
//        // 指定Z轴的话，就和UIView的动画一样绕中心旋转
//        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
//        // 设定动画选项
//        animation.duration = 1 // 持续时间
//        animation.repeatCount = .infinity // 重复次数(如果设成.infinity一直重复下去)
//        // 设定旋转角度
//        animation.fromValue = NSNumber(value: (0 / 180.0 * Double.pi))  //起始角度
//        animation.toValue = NSNumber(value: (360 / 180.0 * Double.pi))   //终止角度
//        // 添加动画
//        imgView.layer.add(animation, forKey: animationKey)
    }
    
    func removeShake(){
        imgView.layer.removeAnimation(forKey: animationKey)
    }
}
