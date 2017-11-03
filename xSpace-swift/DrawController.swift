//
//  DrawController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/2.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit


class DrawController: QtBaseViewController {
    
    var btn:UIButton!
    var panel:QtCornerView!
    var label:UILabel!
    var panel2:UIView!
    var label2:UILabel!
    var count:Int = 1
    var width:CGFloat! = 100
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "draw rect of view"
        
        btn = QtViewFactory.button(text: "reshape", font: QtFont.regularPF(17), textColor: QtColor.blue, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionChangeShape), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        //
        panel = QtCornerView(corners:[UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadius:10)
        panel.backgroundColor = QtColor.green
        label = QtViewFactory.label(font: QtFont.regularPF(12), title: "\(count)", color: QtColor.black)
        panel.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.width.equalTo(80)
            make.height.equalTo(17)
        }
        self.view.addSubview(panel)
        panel.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(30)
            make.centerX.equalTo(btn.snp.centerX)
            make.width.equalTo(width)
            make.height.equalTo(width/2)
        }
        
        //
        panel2 = UIView()
        panel2.backgroundColor = QtColor.green
        label2 = QtViewFactory.label(font: QtFont.regularPF(12), title: "\(count)", color: QtColor.black)
        panel2.addSubview(label2)
        label2.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.width.equalTo(80)
            make.height.equalTo(17)
        }
        self.view.addSubview(panel2)
        panel2.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(150)
            make.centerX.equalTo(btn.snp.centerX)
            make.width.equalTo(width)
            make.height.equalTo(width/2)
        }
        let maskPath = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:width, height:width/2),
                                    byRoundingCorners: [.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        panel2.layer.mask = shape
    }
    
    @objc func actionChangeShape(){
        //模拟view尺寸改变
        width = width == 100 ? 200 : 100
        panel.snp.remakeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(30)
            make.centerX.equalTo(btn.snp.centerX)
            make.width.equalTo(width)
            make.height.equalTo(width/2)
        }
        
        panel2.snp.remakeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(150)
            make.centerX.equalTo(btn.snp.centerX)
            make.width.equalTo(width)
            make.height.equalTo(width/2)
        }
        //模拟view内容改变
        count += 1
        label.text = "\(count)"
        label2.text = "\(count)"
        
        //调用下面两句，drawRect才会调用
        panel.setNeedsDisplay()
        panel2.setNeedsDisplay()
    }
}
