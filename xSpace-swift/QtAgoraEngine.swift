//
//  QtAgoraEngine.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/14.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtAgoraEvent{
    static let ConnectStatusChanged:String = "QtAgoraEvent.ConnectStatusChanged"
    static let ConnectStatusKey:String = "QtAgoraEvent.ConnectStatusKey"
    static let AudientConnected:String = "QtAgoraEvent.AudientConnected"
    static let AudientUidKey:String = "QtAgoraEvent.AudientUidKey"
    static let AudientDisconnected:String = "QtAgoraEvent.AudientDisconnected"
}

enum QtAgoraConnectStatus{
    case stop
    case connecting
    case connected
}

protocol QtAgoraEnginDelegate: class{
    func shouldSubscribeUid(_ uid:UInt) -> Bool
}

class QtAgoraEngine: NSObject,AgoraLiveDelegate,AgoraLivePublisherDelegate,AgoraLiveSubscriberDelegate {
    
    static let agoraAppId = "e113311f89174445a7d20f79662ef006"
    var channel:String!
    var publisherId:UInt!
    var pushStreamUrl:String?
    var liveKit:AgoraLiveKit!
    var channelConfig:AgoraLiveChannelConfig!
    var publisher:AgoraLivePublisher!
    var subscriber:AgoraLiveSubscriber!
    weak var delegate:QtAgoraEnginDelegate?
    
    deinit{
        self.stopLive()
    }
    
    init(channel:String, pushStreamUrl:String?, publisherId:UInt){
        super.init()
        self.channel = channel
        self.publisherId = publisherId
        self.pushStreamUrl = pushStreamUrl
        //
        self.liveKit = AgoraLiveKit.sharedLiveKit(withAppId: QtAgoraEngine.agoraAppId)
        liveKit.delegate = self
        //
        self.publisher = AgoraLivePublisher(liveKit: liveKit)
        publisher.setDelegate(self)
        if(pushStreamUrl != nil){
            publisher.addStreamUrl(self.pushStreamUrl!, transcodingEnabled: false)
        }
        //
        self.subscriber = AgoraLiveSubscriber(liveKit: liveKit)
        subscriber.setDelegate(self)
        //
        self.channelConfig = AgoraLiveChannelConfig.default()
        channelConfig.videoEnabled = false
    }
    
    //静音／关闭静音
    func muteLocalAudioStream(_ muted:Bool){
        liveKit.getRtcEngineKit().muteLocalAudioStream(muted)
    }
    
    func startLive(){
        liveKit.joinChannel(channel, key: nil, config: channelConfig, uid: publisherId)
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: QtAgoraConnectStatus.connecting])
    }
    
    func stopLive(){
        publisher.unpublish()
        liveKit.leaveChannel()
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: QtAgoraConnectStatus.stop])
    }
    
    // 主播踢人，还是需要等到观众断开主播收到 unpublishedByHostUid 事件后才真正断开
    func sendUnpublishRequest(_ uid:UInt){
        publisher.sendUnpublishingRequest(toUid: uid)
    }
    
    //MARK: - Agora Delegate
    
    // 加入频道成功
    func liveKit(_ kit: AgoraLiveKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        publisher.publish(withPermissionKey: nil)
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: QtAgoraConnectStatus.connected])
    }
    
    // SDK 遇到错误。SDK 在加入频道失败时会自动进行重试。
    func liveKit(_ kit: AgoraLiveKit, didOccurError errorCode: AgoraErrorCode) {
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: QtAgoraConnectStatus.connecting])
    }
    
    // 重新加入频道成功
    func liveKit(_ kit: AgoraLiveKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: QtAgoraConnectStatus.connected])
    }
    
    // 频道内主播信息
    func subscriber(_ subscriber: AgoraLiveSubscriber, publishedByHostUid uid: UInt, streamType type: AgoraMediaType) {
        if(delegate != nil){
            if(delegate!.shouldSubscribeUid(uid)){
                subscriber.subscribe(toHostUid: uid,    // uid: 主播 uid
                    mediaType: .audioOnly,  // mediaType: 订阅的数据类型
                    view: nil,              // view: 视频数据渲染显示的视图
                    renderMode: .hidden,    // renderMode: 视频数据渲染方式
                    videoType: .high        // videoType: 大小流
                )
                QtNotice.shared.postEvent(QtAgoraEvent.AudientConnected, userInfo: [QtAgoraEvent.AudientUidKey: uid])
            }
            return
        }
        else{
            subscriber.subscribe(toHostUid: uid,    // uid: 主播 uid
                mediaType: .audioOnly,  // mediaType: 订阅的数据类型
                view: nil,              // view: 视频数据渲染显示的视图
                renderMode: .hidden,    // renderMode: 视频数据渲染方式
                videoType: .high        // videoType: 大小流
            )
            QtNotice.shared.postEvent(QtAgoraEvent.AudientConnected, userInfo: [QtAgoraEvent.AudientUidKey: uid])
        }
    }
    
    // 频道内主播结束直播
    func subscriber(_ subscriber: AgoraLiveSubscriber, unpublishedByHostUid uid: UInt) {
        subscriber.unsubscribe(toHostUid: uid)
        QtNotice.shared.postEvent(QtAgoraEvent.AudientDisconnected, userInfo: [QtAgoraEvent.AudientUidKey: uid])
    }
}
