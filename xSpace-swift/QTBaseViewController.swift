//
//  QTBaseViewController.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/13.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

enum BarButtonItemPosition{
    case left
    case right
}

class QtBaseViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }
    
    func prepare(){
        //控制导航栏显示/隐藏
        UIViewController.qt_exchangeViewWillAppear()
        self.qt_prefersNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QtColor.white
        //
        if(self.navigationController != nil){
            //设置导航栏不透明
            self.navigationController!.navigationBar.isTranslucent = false
            //title样式
            self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: QtFont.regularPF(17), NSForegroundColorAttributeName:QtColor.colorFromRGB(rgbValue: 0x333333)]
            //返回和完成按钮颜色
            self.navigationController!.navigationBar.tintColor = QtColor.green//QtColor.colorFromRGBA(rgbValue: 0, alpha: 0.6)
        }
        self.setBarBtnItem(position:.left, imageName: "backBtn", title: nil, target: self, selector: #selector(actionBack))
    }
    
    func setBarBtnItem(position:BarButtonItemPosition = .left, imageName:String?, title:String?, target:AnyObject?, selector:Selector?){
        let btn = UIButton(type:.custom)
        if(imageName != nil){
            let image = UIImage(named:imageName!)!
            btn.setImage(image, for: .normal)
            btn.frame = CGRect(x:0, y:0, width:image.size.width, height:QtDevice.navBarHeight)
        }
        else if(title != nil){
            btn.setTitle(title!, for: .normal)
            btn.setTitleColor(QtColor.colorFromRGBA(rgbValue: 0, alpha: 0.6), for: .normal)
            btn.titleLabel!.font = QtFont.regularPF(14)
            btn.frame = CGRect(x:0, y:0, width:14*title!.count, height:14)
        }
        btn.contentHorizontalAlignment = position == BarButtonItemPosition.left ? UIControlContentHorizontalAlignment.left : UIControlContentHorizontalAlignment.right
        if(target != nil && selector != nil){
            btn.addTarget(target!, action: selector!, for: .touchUpInside)
        }
        let item = UIBarButtonItem(customView:btn)
        if (position == .left) {
            self.navigationItem.leftBarButtonItem = item;
        } else {
            self.navigationItem.rightBarButtonItem = item;
        }
    }
    
    @objc func actionBack(){
        if(self.navigationController != nil){
            self.navigationController!.popViewController(animated: true)
        }
    }
}
