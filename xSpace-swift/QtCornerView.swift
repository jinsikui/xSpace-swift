//
//  CornerView.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/2.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
/**
 可以任意指定view的四个角中哪些需要圆角
 在autolayout的情况下，无法根据view的frame来设置layer.mask的尺寸，这个类通过覆盖draw(rect:)实现
 必须在view尺寸改变后调用setNeedsDisplay()方法来触发draw(rect:)
 **/
class QtCornerView: UIView {
    
    var corners:UIRectCorner! = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    var cornerRadius:CGFloat! = 10
    
    init(corners:UIRectCorner, cornerRadius:CGFloat){
        super.init(frame: CGRect.zero)
        self.corners = corners
        self.cornerRadius = cornerRadius
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let maskPath = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: self.corners,
                                    cornerRadii: CGSize(width: self.cornerRadius, height:self.cornerRadius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
}
