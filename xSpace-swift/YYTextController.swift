//
//  YYTextController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/31.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import AlamofireImage
import YYText

class YYTextController: QtBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QtColor.white
        
        let titleLabel = YYLabel()
        titleLabel.numberOfLines = 0
        let titleAttr = NSMutableAttributedString()
        //主播／房管 勋章 皇冠 level 名字
        let role = 1
        var url = "https://sss.qingting.fm/pms/config/priv/role/\(role)@2x.png"
        var size = CGSize(width:32,height:15)
        var font = QtFont.regularPF(12)
        titleAttr.qt_appendImg(url: url, size: size, alignTo: font).yy_appendString(" ")
        //
        let medals = [1,2]
        for i in medals{
            url = "https://sss.qingting.fm/pms/config/priv/medal/\(i)@2x.png"
            size = CGSize(width:43,height:15)
            font = QtFont.regularPF(12)
            titleAttr.qt_appendImg(url: url, size: size, alignTo: font).yy_appendString(" ")
        }
        titleAttr.qt_appendStr("我们在天上的父，愿人都遵父的名为圣，愿父的国降临，愿父的旨意", foreColor: QtColor.black, font: QtFont.regularPF(12))
        let width:CGFloat = 200
        let totalSize = titleAttr.qt_sizeWithMaxWidth(maxWidth: width)
        //
        titleLabel.attributedText = titleAttr
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.left.equalTo(100)
            make.width.equalTo(totalSize.width)
            make.height.equalTo(totalSize.height)
        }
        
    }
}
