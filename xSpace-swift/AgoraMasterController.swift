//
//  AgoraMasterController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/12/28.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class AgoraMasterController: QtBaseViewController,AgoraLiveDelegate,AgoraLivePublisherDelegate,AgoraLiveSubscriberDelegate {
    
    let agoraAppId = "e113311f89174445a7d20f79662ef006"
    var channel:String = "100000000"
    var uid:UInt = 100000000
    var agoraEngine:QtAgoraEngine!
    var audioFilePath = ""
    var audioFilePath2 = ""
    var status:QtAgoraConnectStatus = .stop
    var audioEffectBtn:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Agora Master"
        //音频文件路径
        self.audioFilePath = Bundle.main.path(forResource: "laugh", ofType: "mp3")!
        self.audioFilePath2 = Bundle.main.path(forResource: "ghost", ofType: "wav")!
        //
        var btn = QtViewFactory.button(text: "音效1", font: QtFont.regularPF(15), textColor: QtColor.black, bgColor: QtColor.clear, cornerRadius: 2, borderColor: QtColor.black, borderWidth: 0.5)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }
        btn.addTarget(self, action: #selector(actionAudioEffect), for: .touchUpInside)
        
        let btn1 = btn
        btn = QtViewFactory.button(text: "音效2", font: QtFont.regularPF(15), textColor: QtColor.black, bgColor: QtColor.clear, cornerRadius: 2, borderColor: QtColor.black, borderWidth: 0.5)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(btn1.snp.bottom).offset(20)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }
        btn.addTarget(self, action: #selector(actionAudioEffect2), for: .touchUpInside)
        
        let btn2 = btn
        btn = QtViewFactory.button(text: "stop", font: QtFont.regularPF(15), textColor: QtColor.black, bgColor: QtColor.clear, cornerRadius: 2, borderColor: QtColor.black, borderWidth: 0.5)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(btn2.snp.bottom).offset(20)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }
        btn.addTarget(self, action: #selector(actionStop), for: .touchUpInside)
        
        QtNotice.shared.registerEvent(QtAgoraEvent.ConnectStatusChanged, lifeIndicator: self) { [unowned self] (param) in
            let connStatus = (param as! Dictionary<String, Any>)[QtAgoraEvent.ConnectStatusKey] as! QtAgoraConnectStatus
            self.status = connStatus
            switch connStatus{
            case .connected:
                break
            case .connecting:
                break
            case .stop:
                break
            case .streamError:
                break
            case .sdkError:
                break
            }
            
        }
        self.agoraEngine = QtAgoraEngine(channel: self.channel,
                                         pushStreamUrl: "rtmp://pili-publish.partner.zhibo.qingting.fm/qingting-zhibo-partner/test_agora3",
                                         publisherId: self.uid,
                                         agoraKey:nil)
        self.agoraEngine.startLive()
        
    }
    
    func actionStop(){
        self.agoraEngine!.stopAudioEffect()
    }
    
    func actionAudioEffect(){
        if(self.status == .connected){
            self.agoraEngine!.startAudioEffect(filePath: self.audioFilePath)
        }
    }
    
    func actionAudioEffect2(){
        if(self.status == .connected){
            self.agoraEngine!.startAudioEffect(filePath: self.audioFilePath2)
        }
    }
    
    deinit{
        self.agoraEngine.stopLive()
    }
}
