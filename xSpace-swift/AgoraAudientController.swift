//
//  AgoraController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/17.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class AgoraAudientController: QtBaseViewController,AgoraLiveDelegate,AgoraLivePublisherDelegate,AgoraLiveSubscriberDelegate {
    
    let agoraAppId = "e113311f89174445a7d20f79662ef006"
    var channel:String = "100001065"
    var uid:UInt = 444
    var agoraEngine:QtAgoraEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Agora Audient"
        self.agoraEngine = QtAgoraEngine(channel: self.channel,
                                         pushStreamUrl: nil,
                                         publisherId: self.uid)
        self.agoraEngine.startLive()
    }
}
