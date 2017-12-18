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
    static let NetworkStatusChanged:String = "QtAgoraEvent.NetworkStatusChanged"
    static let NetworkStatusKey:String = "QtAgoraEvent.NetworkStatusKey"
    static let AudienceConnected:String = "QtAgoraEvent.AudienceConnected"
    static let AudienceUidKey:String = "QtAgoraEvent.AudienceUidKey"
    static let AudienceDisconnected:String = "QtAgoraEvent.AudienceDisconnected"
    static let SelfVolumeInfo:String = "QtAgoraEvent.SelfVolumeInfo"
    static let SelfVolumeInfoKey:String = "QtAgoraEvent.SelfVolumeInfoKey"
    static let AudienceVolumesInfo:String = "QtAgoraEvent.AudienceVolumesInfo"
    static let AudienceVolumesInfoKey:String = "QtAgoraEvent.AudienceVolumesInfoKey"
}

enum QtAgoraConnectStatus{
    case stop
    case connecting
    case connected
    case streamError
    case sdkError
}

enum QtAgoraNetworkStatus{
    case unknown
    case good
    case bad
    case down
}

protocol QtAgoraEnginDelegate: class{
    func shouldSubscribeUid(_ uid:UInt) -> Bool
}

class QtAgoraEngine: NSObject,AgoraLiveDelegate,AgoraLivePublisherDelegate,AgoraLiveSubscriberDelegate,AgoraRtcEngineDelegate {
    
    static let agoraAppId = "e113311f89174445a7d20f79662ef006"
    static let speakerVolumesCallbackInterval = 1000    //milliseconds
    var channel:String!
    var publisherId:UInt!
    var pushStreamUrl:String?
    private var _status:QtAgoraConnectStatus = .stop
    var status:QtAgoraConnectStatus{
        get{
            return _status
        }
        set{
            QtSwift.print("===== status change to:\(newValue) =====")
            _status = newValue
            QtNotice.shared.postEvent(QtAgoraEvent.ConnectStatusChanged, userInfo: [QtAgoraEvent.ConnectStatusKey: newValue])
        }
    }
    //由于网络断开时并不会触发推流失败的回调，所以网络状态和连接状态用两个独立变量表示
    private var _networkStatus:QtAgoraNetworkStatus = .unknown
    var networkStatus:QtAgoraNetworkStatus{
        get{
            return _networkStatus
        }
        set{
            //QtSwift.print("===== networkStatus change to:\(newValue) =====")
            _networkStatus = newValue
            QtNotice.shared.postEvent(QtAgoraEvent.NetworkStatusChanged, userInfo: [QtAgoraEvent.NetworkStatusKey: newValue])
        }
    }
    var liveKit:AgoraLiveKit!
    var channelConfig:AgoraLiveChannelConfig!
    var publisher:AgoraLivePublisher!
    var subscriber:AgoraLiveSubscriber!
    weak var delegate:QtAgoraEnginDelegate?
    
    deinit{
        self.stopLive()
    }
    
    init(channel:String, pushStreamUrl:String?, publisherId:UInt){
        QtSwift.print("===== init QtAgoraEngine channel:\(channel) pushStreamUrl:\(pushStreamUrl!)")
        super.init()
        self.channel = channel
        self.publisherId = publisherId
        self.pushStreamUrl = pushStreamUrl
        //
        self.liveKit = AgoraLiveKit.sharedLiveKit(withAppId: QtAgoraEngine.agoraAppId)
        liveKit.delegate = self
        liveKit.getRtcEngineKit().setEngineDelegate(self)
        // 接收谁在说话的回调
        liveKit.getRtcEngineKit().enableAudioVolumeIndication(QtAgoraEngine.speakerVolumesCallbackInterval, smooth: 3)
        //
        self.publisher = AgoraLivePublisher(liveKit: liveKit)
        publisher.setMediaType(.audioOnly)
        publisher.setDelegate(self)
        //
        self.subscriber = AgoraLiveSubscriber(liveKit: liveKit)
        subscriber.setDelegate(self)
        //
        self.channelConfig = AgoraLiveChannelConfig.default()
        channelConfig.videoEnabled = false
    }
    
    //静音／关闭静音
    func muteLocalAudioStream(_ muted:Bool){
        QtSwift.print("===== muteLocalAudioStream muted:\(muted) =====")
        liveKit.getRtcEngineKit().muteLocalAudioStream(muted)
    }
    
    // 应该可重入
    func startLive(){
        QtSwift.print("===== startLive =====")
        if(self.status == .stop){
            self.status = .connecting
            liveKit.joinChannel(channel, key: nil, config: channelConfig, uid: publisherId)
        }
    }
    
    // 应该可重入
    func startLive(pushStreamUrl:String){
        QtSwift.print("===== startLive pushStreamUrl:\(pushStreamUrl) =====")
        if(self.status == .stop){
            self.pushStreamUrl = pushStreamUrl
            self.startLive()
        }
        else{
            if(pushStreamUrl == self.pushStreamUrl){
                return
            }
            self.status = .connecting
            self.pushStreamUrl = pushStreamUrl
            publisher.addStreamUrl(self.pushStreamUrl!, transcodingEnabled: false)
        }
    }
    
    // 应该可重入
    func stopLive(){
        QtSwift.print("===== stopLive =====")
        if(self.status == .stop){
            return
        }
        self.status = .stop
        publisher.unpublish()
        liveKit.leaveChannel()
    }
    
    // 主播踢人，还是需要等到观众断开主播收到 unpublishedByHostUid 事件后才真正断开
    func sendUnpublishRequest(_ uid:UInt){
        publisher.sendUnpublishingRequest(toUid: uid)
    }
    
    //MARK: - Agora Delegate
    
    // 加入频道成功
    func liveKit(_ kit: AgoraLiveKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        QtSwift.print("===== liveKit didJoinChannel:\(channel) uid:\(uid) =====")
        self.status = .connecting
        publisher.publish(withPermissionKey: nil)
        if(self.pushStreamUrl != nil){
            publisher.addStreamUrl(self.pushStreamUrl!, transcodingEnabled: false)
        }
    }
    
    // SDK 遇到错误。SDK 在加入频道失败时会自动进行重试。
    func liveKit(_ kit: AgoraLiveKit, didOccurError errorCode: AgoraErrorCode) {
        self.status = .sdkError
        QtSwift.print("===== liveKit didOccurError rawValue:\(errorCode.rawValue) =====")
    }
    
    // 重新加入频道成功
    func liveKit(_ kit: AgoraLiveKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        QtSwift.print("===== liveKit didRejoinChannel:\(channel) uid:\(uid) =====")
        publisher.publish(withPermissionKey: nil)
    }
    
    /**
     *  Event of disconnected with server. This event is reported at the moment SDK loses connection with server.
     *  In the mean time SDK automatically tries to reconnect with the server until APP calls leaveChannel.
     *
     *  @param kit    The live kit
     */
    func liveKitConnectionDidInterrupted(_ kit: AgoraLiveKit) {
        QtSwift.print("===== liveKit ConnectionDidInterrupted =====")
    }
    
    /**
     *  Event of loss connection with server. This event is reported after the connection is interrupted and exceed the retry period (10 seconds by default).
     *  In the mean time SDK automatically tries to reconnect with the server until APP calls leaveChannel.
     *
     *  @param kit    The live kit
     */
    func liveKitConnectionDidLost(_ kit: AgoraLiveKit) {
        QtSwift.print("===== liveKit ConnectionDidLost =====")
    }
    
    /**
     *  The network quality of local user.
     *
     *  @param kit     The live kit
     *  @param uid     The id of user
     *  @param txQuality The sending network quality
     *  @param rxQuality The receiving network quality
     */
    func liveKit(_ kit: AgoraLiveKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        //QtSwift.print("===== liveKit networkQuality uid:\(uid) sendingQuality:\(txQuality.rawValue) receivingQuality:\(rxQuality.rawValue) =====")
        switch txQuality{
        case .unknown:
            self.networkStatus = .unknown
        case .excellent,.good:
            self.networkStatus = .good
        case .poor,.bad,.vBad:
            self.networkStatus = .bad
        case .down:
            self.networkStatus = .down
        }
    }
    
    func publisher(_ publisher: AgoraLivePublisher, streamPublishedWithUrl url: String, error: AgoraErrorCode) {
        QtSwift.print("===== publisher streamPublishedWithUrl:\(url) errorRawValue:\(error.rawValue) =====")
        if(error.rawValue != 0){
            self.status = .streamError
        }
        else{
            self.status = .connected
        }
    }
    
    // may caused by .unpublish() or .removeStreamUrl() call
    func publisher(_ publisher: AgoraLivePublisher, streamUnpublishedWithUrl url: String) {
        QtSwift.print("===== publisher streamUnpublishedWithUrl:\(url) =====")
        
    }
    
    // 频道内主播信息
    func subscriber(_ subscriber: AgoraLiveSubscriber, publishedByHostUid uid: UInt, streamType type: AgoraMediaType) {
        QtSwift.print("===== subscriber publishedByHostUid:\(uid) =====")
        if(delegate == nil){
            subscriber.subscribe(toHostUid: uid,    // uid: 主播 uid
                mediaType: .audioOnly,  // mediaType: 订阅的数据类型
                view: nil,              // view: 视频数据渲染显示的视图
                renderMode: .hidden,    // renderMode: 视频数据渲染方式
                videoType: .high        // videoType: 大小流
            )
            QtNotice.shared.postEvent(QtAgoraEvent.AudienceConnected, userInfo: [QtAgoraEvent.AudienceUidKey: uid])
        }
        else{
            if(delegate!.shouldSubscribeUid(uid)){
                subscriber.subscribe(toHostUid: uid,    // uid: 主播 uid
                    mediaType: .audioOnly,  // mediaType: 订阅的数据类型
                    view: nil,              // view: 视频数据渲染显示的视图
                    renderMode: .hidden,    // renderMode: 视频数据渲染方式
                    videoType: .high        // videoType: 大小流
                )
                QtNotice.shared.postEvent(QtAgoraEvent.AudienceConnected, userInfo: [QtAgoraEvent.AudienceUidKey: uid])
            }
            else{
                //如果不该连麦的人加入了channel，请求他退出
                publisher.sendUnpublishingRequest(toUid: uid)
            }
        }
    }
    
    // 频道内主播结束直播
    func subscriber(_ subscriber: AgoraLiveSubscriber, unpublishedByHostUid uid: UInt) {
        QtSwift.print("===== subscriber unpublishedByHostUid:\(uid) =====")
        subscriber.unsubscribe(toHostUid: uid)
        QtNotice.shared.postEvent(QtAgoraEvent.AudienceDisconnected, userInfo: [QtAgoraEvent.AudienceUidKey: uid])
    }
    
    /**
     *  The sdk reports the volume of a speaker. The interface is disable by default, and it could be enable by API "enableAudioVolumeIndication"
     *
     *  @param engine      The engine kit
     *  @param speakers    AgoraRtcAudioVolumeInfos array
     *  @param totalVolume The total volume of speakers
     */
    func rtcEngine(_ engine: AgoraRtcEngineKit!, reportAudioVolumeIndicationOfSpeakers speakers: [Any]!, totalVolume: Int) {
        //QtSwift.print("===== rtcEngine reportAudioVolumeIndicationOfSpeakers =====")
        if(speakers.count == 1 && (speakers[0] as! AgoraRtcAudioVolumeInfo).uid == 0){
            //自己说话信息
            let info = speakers[0] as! AgoraRtcAudioVolumeInfo
            info.uid = self.publisherId
            QtNotice.shared.postEvent(QtAgoraEvent.SelfVolumeInfo, userInfo: [QtAgoraEvent.SelfVolumeInfoKey: info])
            return;
        }
        else{
            var audienceArr = Array<AgoraRtcAudioVolumeInfo>()
            for o in speakers{
                let info = o as! AgoraRtcAudioVolumeInfo
                if(info.uid == 0){
                    //自己说话信息
                    info.uid = self.publisherId
                    QtNotice.shared.postEvent(QtAgoraEvent.SelfVolumeInfo, userInfo: [QtAgoraEvent.SelfVolumeInfoKey: info])
                }
                else{
                    audienceArr.append(info)
                }
            }
            QtNotice.shared.postEvent(QtAgoraEvent.AudienceVolumesInfo, userInfo: [QtAgoraEvent.AudienceVolumesInfoKey: audienceArr])
        }
    }
}
