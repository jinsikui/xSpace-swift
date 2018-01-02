//
//  AnimationController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/12/28.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class AnimationController: QtBaseViewController {
    
    var box:UIView?
    var v1:UIView?
    var v2:UIView?
    var v3:UIView?
    var isAnimationInit = false
    var isAnimationRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Animation"
        
        let box = UIView()
        self.box = box
        box.layer.borderColor = QtColor.green.cgColor
        box.layer.borderWidth = 0.5
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(80)
        }
        self.resetViewsInBox()
        
        let btn = QtViewFactory.button(text: "start/pause", font: QtFont.regularPF(15), textColor: QtColor.blue, bgColor: QtColor.clear, cornerRadius: 2, borderColor: QtColor.blue, borderWidth: 0.5)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(box.snp.bottom).offset(20)
            make.centerX.equalTo(box.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        btn.addTarget(self, action: #selector(actionChangeAnimation), for: .touchUpInside)
        
        let resetBtn = QtViewFactory.button(text: "reset", font: QtFont.regularPF(15), textColor: QtColor.blue, bgColor: QtColor.clear, cornerRadius: 2, borderColor: QtColor.blue, borderWidth: 0.5)
        self.view.addSubview(resetBtn)
        resetBtn.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(20)
            make.centerX.equalTo(box.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        resetBtn.addTarget(self, action: #selector(actionReset), for: .touchUpInside)
    }
    
    func resetViewsInBox(){
        self.v1?.removeFromSuperview()
        self.v2?.removeFromSuperview()
        self.v3?.removeFromSuperview()
        
        let v1 = UIView()
        self.v1 = v1
        v1.frame = CGRect(x: 10, y: 55, width: 20, height: 25)
        v1.backgroundColor = QtColor.green
        self.box!.addSubview(v1)
        
        let v2 = UIView()
        self.v2 = v2
        v2.frame = CGRect(x: 40, y: 55, width: 20, height: 25)
        v2.backgroundColor = QtColor.green
        self.box!.addSubview(v2)
        
        let v3 = UIView()
        self.v3 = v3
        v3.frame = CGRect(x: 70, y: 55, width: 20, height: 25)
        v3.backgroundColor = QtColor.green
        self.box!.addSubview(v3)
    }
    
    @objc func actionReset(){
        self.reset()
    }
    
    @objc func actionChangeAnimation(){
        if(self.isAnimationRunning){
            self.pause()
        }
        else{
            self.start()
        }
    }
    
    var viewsInBox:Array<UIView>{
        get{
            return [self.v1!, self.v2!, self.v3!]
        }
    }
    
    func dispose(){
        for v in self.viewsInBox{
            v.layer.removeAllAnimations()
        }
    }
    
    func reset(){
        self.dispose()
        self.resetViewsInBox()
        self.isAnimationInit = false
        self.isAnimationRunning = false
    }
    
    func start(){
        if(!isAnimationInit){
            
            isAnimationInit = true
            isAnimationRunning = true
            
            let duration = 0.3
            var delay = 0.0
            let delta = 0.1
            for v in self.viewsInBox{
                UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut, .autoreverse, .repeat], animations: {[weak self] in
                    self?._animationFor(v)
                }, completion: nil)
                delay += delta
            }
        }
        else{
            self.resume()
        }
    }
    
    func _animationFor(_ view:UIView){
        view.frame = CGRect(x: view.frame.origin.x, y: 10, width: 20, height: 70)
    }
    
    func pause(){
        if(!isAnimationRunning){
            return
        }
        isAnimationRunning = false
        for v in self.viewsInBox{
            let layer = v.layer
            self._pause(layer: layer)
        }
    }
    
    func _pause(layer:CALayer){
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }
    
    func resume(){
        if(isAnimationRunning){
            return
        }
        isAnimationRunning = true
        for v in self.viewsInBox {
            let layer = v.layer
            self._resume(layer: layer)
        }
    }
    
    func _resume(layer:CALayer){
        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    deinit{
        self.dispose()
    }
}
