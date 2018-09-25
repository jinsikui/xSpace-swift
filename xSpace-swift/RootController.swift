//
//  RootController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/11.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import SwiftyJSON

class RootController: UIViewController {
    
    var scroll:UIScrollView!
    var timer: DispatchSourceTimer!
    var isTimerRunning = false
    internal let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        timer.setEventHandler {
            self.timerTicking()
        }
        
        scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        self.view.addSubview(scroll)
        scroll.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        //
        self.createBtn("WebView", y: 50, action: #selector(self.actionQtWebView))
        self.createBtn("exchange method", y: 120, action: #selector(self.actionMethodExchange))
        self.createBtn("yy text", y: 190, action: #selector(self.actionYYText))
        self.createBtn("get json", y: 260, action: #selector(self.actionGetJson))
        self.createBtn("hex color", y: 330, action: #selector(self.actionHexColor))
        self.createBtn("draw rect", y: 400, action: #selector(self.actionDrawRect))
        self.createBtn("timer", y: 470, action: #selector(self.actionTimer))
        self.createBtn("notice", y: 540, action: #selector(self.actionNotice))
        self.createBtn("GridView", y: 610, action: #selector(self.actionGridView))
        self.createBtn("KVO", y: 680, action: #selector(self.actionKVO))
        self.createBtn("Agora Master", y: 750, action: #selector(self.actionAgoraMaster))
        self.createBtn("Nullable", y: 820, action: #selector(self.actionNullable))
        self.createBtn("Substring", y: 890, action: #selector(self.actionSubString))
        self.createBtn("deviceInfo", y: 960, action: #selector(self.actionDevice))
        self.createBtn("RxSwift", y: 1030, action: #selector(self.actionRxSwift))
        self.createBtn("Animation", y: 1100, action: #selector(self.actionAnimation))
        self.createBtn("CollectionView", y: 1170, action: #selector(self.actionCollectionView))
        self.createBtn("QtToast", y: 1240, action: #selector(self.actionToast))
        self.createBtn("QtToast inView", y: 1310, action: #selector(self.actionToastInView))
        self.createBtn("UI Test", y: 1380, action: #selector(self.actionUITest))
        self.createBtn("Animations", y: 1450, action: #selector(self.actionAnimations))
        //
        scroll.contentSize = CGSize(width:0, height:1550)
    }
    
    @objc func actionAnimations(){
        self.navigationController!.pushViewController(AnimationsController(), animated: true)
    }
    
    @objc func actionUITest(){
        self.navigationController!.pushViewController(UITestController(), animated: true)
    }
    
    @objc func actionToastInView(){
        QtToast.show("哈哈哈", duration: 2, distanceToBottom: 30, inView: self.view)
    }
    
    @objc func actionToast(){
        QtToast.show("哈哈哈哈哈哈")
    }
    
    @objc func actionCollectionView(){
        self.navigationController!.pushViewController(CollectionViewController(), animated: true)
    }
    
    @objc func actionAnimation(){
        self.navigationController!.pushViewController(AnimationController(), animated: true)
    }
    
    @objc func actionRxSwift(){
        self.navigationController!.pushViewController(RxSwiftController(), animated: true)
    }
    
    @objc func actionDevice(){
        QtSwift.print("===== deviceModel:\(QtDevice.deviceModel) iosRawVersion:\(QtDevice.iosRawVersion) =====")
    }
    
    @objc func actionSubString(){
        let str = "Hello world"
        QtSwift.print("===== \(str.qt_subString(0, len: 7)) =====")
    }
    
    @objc func actionNullable(){
        let obj = MyObject()
        obj.age = 3
        obj.name = "jsk"
        QtSwift.print("===== \(obj.age) \(obj.name) =====")
        QtSwift.print("===== \(obj.age == 3) =====")
    }
    
    @objc func actionAgoraMaster(){
        self.navigationController!.pushViewController(AgoraMasterController(), animated: true)
    }
    
    @objc func actionKVO(){
        self.navigationController!.pushViewController(KVOTestController(), animated: true)
    }
    
    @objc func actionGridView(){
        self.navigationController!.pushViewController(GridViewController(), animated: true)
    }
    
    @objc func actionNotice(){
        self.navigationController!.pushViewController(NoticeController(), animated: true)
    }
    
    var count = 0
    @objc func timerTicking(){
        count += 1
        print("=====\(count)=====")
    }
    
    @objc func actionTimer(){
        if(!isTimerRunning){
            timer.resume()
            isTimerRunning = true
        }
        else{
            timer.suspend()
            isTimerRunning = false
        }
    }
    
    @objc func actionHexColor(){
        let color = QtColor.fromHexString("#FF0000")
        self.view.backgroundColor = color
    }
    
    @objc func actionGetJson(){
        let has = QtFile.shared.hasDocumentFile(filename: QtFile.levelColorsFileName)
        if(has){
            let json = QtFile.shared.getFromDocument(filename: QtFile.levelColorsFileName)!
            print(json)
        }
        API.shared
            .getLevelColor()
            .subscribe(onNext: { (r, json) in
                if let json = json as? JSON {
                    QtFile.shared.saveToDocument(filename: QtFile.levelColorsFileName, json: json)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func actionDrawRect(){
        self.navigationController!.pushViewController(DrawController(), animated: true)
    }
    
    @objc func actionYYText(){
        self.navigationController!.pushViewController(YYTextController(), animated: true)
    }
    
    @objc func actionQtWebView(){
        self.navigationController!.pushViewController(QtWebViewController(), animated: true)
    }
    
    @objc func actionMethodExchange(_ sender: Any) {
        self.navigationController!.pushViewController(AViewController(), animated: true)
    }
    
    func createBtn(_ name:String, y:CGFloat, action:Selector){
        let btn = QtViewFactory.button(text: name, font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: action, for: .touchUpInside)
        let x = CGFloat(0.5*(QtDevice.screenWidth - 150))
        btn.frame = CGRect(x: x, y: y, width: 150, height: 50)
        scroll.addSubview(btn)
    }
}
