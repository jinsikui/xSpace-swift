//
//  AgoraBroadcasterController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/17.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class AgoraBroadcasterController: QtBaseViewController,AgoraLiveDelegate,AgoraLivePublisherDelegate,AgoraLiveSubscriberDelegate {
    
    let agoraAppId = "e113311f89174445a7d20f79662ef006"
    var channel:String = "100001065"
    var uid:UInt = 100001065
    var agoraEngine:QtAgoraEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Agora Broadcaster"
        self.agoraEngine = QtAgoraEngine(channel: self.channel,
                                         pushStreamUrl: "rtmp://pili-publish.staging.zhibo.qingting.fm/qingting-zhibo-staging/dev_100001065_1451d440-23fb-11e7-9b9b-1f6ace6812e6?nonce=1510894820&token=jXD8xmAC7ctKMG2OEA-dYZfu4VE=",
                                         publisherId: self.uid)
        self.agoraEngine.startLive()
    }
}
