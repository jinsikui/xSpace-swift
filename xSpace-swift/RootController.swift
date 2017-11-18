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
        let x = CGFloat(0.5*(QtDevice.screenWidth - 150))
        var btn = QtViewFactory.button(text: "WebView", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(self.actionQtWebView), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 50, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "exchange method", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(self.actionMethodExchange), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 120, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "yy text", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionYYText), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 190, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "get json", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionGetJson), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 260, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "hex color", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionHexColor), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 330, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "draw rect", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionDrawRect), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 400, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "timer", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionTimer), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 470, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "Notice", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionNotice), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 540, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "GridView", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionGridView), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 610, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "KVO", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionKVO), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 680, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "AgoraAudient", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionAgoraAudient), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 750, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        btn = QtViewFactory.button(text: "AgoraBroadcaster", font: QtFont.regularPF(15), textColor:QtColor.blue, bgColor:QtColor.white, cornerRadius: 2, borderColor: QtColor.blue)
        btn.addTarget(self, action: #selector(actionAgoraBroadcaster), for: .touchUpInside)
        btn.frame = CGRect(x: x, y: 820, width: 150, height: 50)
        scroll.addSubview(btn)
        //
        scroll.contentSize = CGSize(width:0, height:970)
    }
    
    @objc func actionAgoraBroadcaster(){
        self.navigationController!.pushViewController(AgoraBroadcasterController(), animated: true)
    }
    
    @objc func actionAgoraAudient(){
        self.navigationController!.pushViewController(AgoraAudientController(), animated: true)
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
}
