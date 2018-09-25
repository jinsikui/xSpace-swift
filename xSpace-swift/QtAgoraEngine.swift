//
//  QtAgoraEngine.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/14.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class QtAgoraEvent{
    static let ConnectStatusChanged:String = "QtAgoraEvent.ConnectStatusChanged"
    static let ConnectStatusKey:String = "QtAgoraEvent.ConnectStatusKey"
    static let NetworkStatusChanged:String = "QtAgoraEvent.NetworkStatusChanged"
    static let NetworkStatusKey:String = "QtAgoraEvent.NetworkStatusKey"
    static let ConnectionLost:String = "QtAgoraEvent.ConnectionLost"
    static let RequestChannelKey:String = "QtAgoraEvent.RequestChannelKey"
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
    
//    #if DEBUG
//    static let agoraAppId = "3107d20858804bc0b86df192bd663be9"  //测试环境
//    #else
//    static let agoraAppId = "523204405737451bac7ccb7d306afe57"  //正式环境
//    #endif
    static let agoraAppId = "e113311f89174445a7d20f79662ef006"  //demo环境
    static let speakerVolumesCallbackInterval = 1000    //milliseconds
    var agoraKey:String?
    var channel:String!
    var publisherId:UInt!
    var users:Array<UInt> = Array()
    var lock = NSLock()
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
    //统计相关
    var startLiveTime:Date?
    var connectTime:Date?
    var commonBeacon:Dictionary<String,Any> = [:]
    
    deinit{
        self.stopLive()
    }
    
    init(channel:String, pushStreamUrl:String?, publisherId:UInt, agoraKey:String?){
        QtSwift.print("===== init QtAgoraEngine channel:\(channel) pushStreamUrl:\(pushStreamUrl!) agoraKey:\(agoraKey == nil ? "null" : agoraKey!)")
        super.init()
        self.channel = channel
        self.agoraKey = agoraKey
        self.publisherId = publisherId
        self.pushStreamUrl = pushStreamUrl == nil ? nil : pushStreamUrl!  //正式代码
        //self.pushStreamUrl = "rtmp://vid-218.push.chinanetcenter.broadcastapp.agora.io/live/123"  //声网测试地址
        //self.pushStreamUrl = "rtmp://pili-publish.partner.zhibo.qingting.fm/qingting-zhibo-partner/test_agora"  //不需要鉴权测试地址
        //
        self.liveKit = AgoraLiveKit.sharedLiveKit(withAppId: QtAgoraEngine.agoraAppId)
        liveKit.delegate = self
        liveKit.getRtcEngineKit().delegate = self
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
    
    func startAudioEffect(filePath:String){
        if(self.status == .connected){
            self.liveKit.getRtcEngineKit().startAudioMixing(filePath, loopback: false, replace: false, cycle: 1)
            QtSwift.print("===== audioMixingDuration(ms): \(self.liveKit.getRtcEngineKit().getAudioMixingDuration()) =====")
        }
    }
    
    func stopAudioEffect(){
        self.liveKit.getRtcEngineKit().stopAudioMixing()
    }
    
    func rtcEngineLocalAudioMixingDidFinish(_ engine: AgoraRtcEngineKit) {
        QtSwift.print("===== rtcEngineLocalAudioMixingDidFinish =====")
    }
    
    //静音／关闭静音
    func muteLocalAudioStream(_ muted:Bool){
        QtSwift.print("===== muteLocalAudioStream muted:\(muted) =====")
        liveKit.getRtcEngineKit().muteLocalAudioStream(muted)
    }
    
    //设置推流参数
    func _updateTranscoding(){
        let transCoding = AgoraLiveTranscoding()
        transCoding.videoBitrate = 1
        //transCoding.videoFramerate = 1
        transCoding.size = CGSize(width: 16, height: 16)
        //transCoding.transcodingExtraInfo = "{\"lowDelay\":true}"
        transCoding.lowLatency = true
        transCoding.transcodingUsers = users.map({ (uid) -> AgoraLiveTranscodingUser in
            let user = AgoraLiveTranscodingUser()
            user.uid = uid
            user.rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            return user
        })
        publisher.setLiveTranscoding(transCoding)
        QtSwift.print("===== publisher.setLiveTranscoding() =====")
    }
    
    // 应该可重入
    func startLive(){
        QtSwift.print("===== startLive =====")
        if(self.status == .stop){
            self.status = .connecting
            liveKit.joinChannel(channel, key: (agoraKey == nil ? nil : agoraKey!), config: channelConfig, uid: publisherId)
            QtSwift.print("===== liveKit.joinChannel() =====")
//            API.shared.sendBeacon(name: "hostinp", event: "chan_join", params: nil, commonParams: self.commonBeacon)
        }
        //
        if(self.startLiveTime == nil){
            self.startLiveTime = Date()
//            API.shared.sendBeacon(name: "hostinp", event: "stream_start", params: nil, commonParams: self.commonBeacon)
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
            if(self.pushStreamUrl == pushStreamUrl){
                return
            }
            self.status = .connecting
            self.pushStreamUrl = pushStreamUrl
            //设置推流参数
            self.lock.lock()
            self._updateTranscoding()
            self.lock.unlock()
            //
            publisher.addStreamUrl(self.pushStreamUrl!, transcodingEnabled: true)
            //硬编码测试
//            publisher.addStreamUrl("rtmp://pili-publish.partner.zhibo.qingting.fm/qingting-zhibo-partner/test_publish", transcodingEnabled: true)
//            publisher.addStreamUrl("rtmp://ds-uswest1.zhibo.qingting.fm:1935/live/100009070", transcodingEnabled: true)
            QtSwift.print("===== publisher.addStreamUrl:\(self.pushStreamUrl!) transcodingEnabled: true =====")
//            API.shared.sendBeacon(name: "hostinp", event: "add_stream_url", params: nil, commonParams: self.commonBeacon)
        }
    }
    
    // 应该可重入
    func stopLive(){
        QtSwift.print("===== stopLive =====")
        if(self.status == .stop){
            return
        }
        self.status = .stop
        if(self.pushStreamUrl != nil){
            publisher.removeStreamUrl(self.pushStreamUrl!)
            QtSwift.print("===== publisher.removeStreamUrl: \(self.pushStreamUrl!) =====")
        }
        self.users = []
        publisher.unpublish()
        QtSwift.print("===== publisher.unpublish() =====")
//        API.shared.sendBeacon(name: "hostinp", event: "unpublish", params: nil, commonParams: self.commonBeacon)
        
        liveKit.leaveChannel()
        QtSwift.print("===== liveKit.leaveChannel() =====")
//        API.shared.sendBeacon(name: "hostinp", event: "chan_leave", params: nil, commonParams: self.commonBeacon)
//        API.shared.sendBeacon(name: "hostinp", event: "stream_stop", params: nil, commonParams: self.commonBeacon)
    }
    
    // 主播踢人，还是需要等到观众断开主播收到 unpublishedByHostUid 事件后才真正断开
    func sendUnpublishRequest(_ uid:UInt){
        QtSwift.print("===== sendUnpublishRequest uid:\(uid) =====")
        publisher.sendUnpublishingRequest(toUid: uid)
    }
    
    //MARK: - Agora Delegate
    
    // 加入频道成功 SDK 在加入频道失败时会自动进行重试。
    func liveKit(_ kit: AgoraLiveKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        QtSwift.print("===== liveKit didJoinChannel:\(channel) uid:\(uid) =====")
//        API.shared.sendBeacon(name: "hostinp", event: "chan_join_success", params: nil, commonParams: self.commonBeacon)
        
        self.status = .connecting
        //设置推流参数
        self.lock.lock()
        if(!users.contains(publisherId!)){
            users.append(publisherId!)
            self._updateTranscoding()
        }
        self.lock.unlock()
        //添加推流地址
        if(self.pushStreamUrl != nil){
            publisher.addStreamUrl(self.pushStreamUrl!, transcodingEnabled: true)
            //硬编码测试
//            publisher.addStreamUrl("rtmp://pili-publish.partner.zhibo.qingting.fm/qingting-zhibo-partner/test_publish", transcodingEnabled: true)
//            publisher.addStreamUrl("rtmp://ds-uswest1.zhibo.qingting.fm:1935/live/100009070", transcodingEnabled: true)
            QtSwift.print("===== publisher.addStreamUrl:\(self.pushStreamUrl!) transcodingEnabled: true =====")
//            API.shared.sendBeacon(name: "hostinp", event: "add_stream_url", params: nil, commonParams: self.commonBeacon)
        }
        //发布自己
        publisher.publish(withPermissionKey: nil)
        QtSwift.print("===== publisher.publish() =====")
//        API.shared.sendBeacon(name: "hostinp", event: "publish", params: nil, commonParams: self.commonBeacon)
    }
    
    // 重新加入频道成功
    func liveKit(_ kit: AgoraLiveKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        QtSwift.print("===== liveKit didRejoinChannel:\(channel) uid:\(uid) =====")
//        API.shared.sendBeacon(name: "hostinp", event: "chan_rejoin_success", params: nil, commonParams: self.commonBeacon)
        //
        publisher.publish(withPermissionKey: nil)
        QtSwift.print("===== publisher.publish() =====")
//        API.shared.sendBeacon(name: "hostinp", event: "publish", params: nil, commonParams: self.commonBeacon)
    }
    
    // SDK 遇到错误。
    func liveKit(_ kit: AgoraLiveKit, didOccurError errorCode: AgoraErrorCode) {
        QtSwift.print("===== liveKit didOccurError errorCode:\(errorCode.rawValue) =====")
        if(errorCode == AgoraErrorCode.channelKeyExpired ||
            errorCode == AgoraErrorCode.invalidChannelKey){
            //在liveKitRequestChannelKey回调中处理
            return
        }
        self.status = .sdkError
//        API.shared.sendBeacon(name: "hostinp", event: "err", params: ["code":errorCode.rawValue], commonParams: self.commonBeacon)
    }
    
    /**
     * when channel key is enabled, and specified channel key is invalid or expired, this function will be called.
     * APP should generate a new channel key and call renewChannelKey() to refresh the key.
     * NOTE: to be compatible with previous version, ERR_CHANNEL_KEY_EXPIRED and ERR_INVALID_CHANNEL_KEY are also reported via onError() callback.
     * You should move renew of channel key logic into this callback.
     *  @param kit The live kit
     */
    func liveKitRequestChannelKey(_ kit: AgoraLiveKit) {
        QtSwift.print("===== liveKitRequestChannelKey =====")
        QtNotice.shared.postEvent(QtAgoraEvent.RequestChannelKey, userInfo: nil)
    }
    
    // 外部获取到新的 agoraKey 之后调用
    func renewChannelKey(_ agoraKey:String){
        QtSwift.print("===== renewChannelKey:\(agoraKey) =====")
        self.agoraKey = agoraKey
        self.liveKit.renewChannelKey(agoraKey)
        QtSwift.print("===== liveKit.renewChannelKey() =====")
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
        QtNotice.shared.postEvent(QtAgoraEvent.ConnectionLost, userInfo: nil)
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
        QtSwift.print("===== publisher streamPublishedWithUrl:\(url) error:\(error.rawValue) =====")
        if(self.pushStreamUrl != nil && url != self.pushStreamUrl!){
            QtSwift.print("===== this is the old url's message =====")
            return
        }
        if(error.rawValue != 0){
            self.status = .streamError
            //
            let elapsed = UInt(Date().timeIntervalSince(self.startLiveTime!))
//            API.shared.sendBeacon(name: "hostinp", event: "stream_publish_failed", params: ["url":url,"du":elapsed,"errorCode":error.rawValue], commonParams: self.commonBeacon)
        }
        else{
            self.status = .connected
            //
            self.connectTime = Date()
            let elapsed = UInt(self.connectTime!.timeIntervalSince(self.startLiveTime!))
//            API.shared.sendBeacon(name: "hostinp", event: "stream_published", params: ["du":elapsed], commonParams: self.commonBeacon)
        }
    }
    
    // may caused by .unpublish() or .removeStreamUrl() call
    func publisher(_ publisher: AgoraLivePublisher, streamUnpublishedWithUrl url: String) {
        QtSwift.print("===== publisher streamUnpublishedWithUrl:\(url) =====")
        //
        var elapsed:UInt = 0
        if(self.connectTime != nil){
            elapsed = UInt(Date().timeIntervalSince(self.connectTime!))
        }
//        API.shared.sendBeacon(name: "hostinp", event: "stream_unpublished", params: ["url":url,"du":elapsed], commonParams: self.commonBeacon)
    }
    
    // 频道内主播信息
    func subscriber(_ subscriber: AgoraLiveSubscriber, publishedByHostUid uid: UInt, streamType type: AgoraMediaType) {
        QtSwift.print("===== subscriber publishedByHostUid:\(uid) =====")
        if(delegate == nil || delegate!.shouldSubscribeUid(uid)){
            subscriber.subscribe(toHostUid: uid,    // uid: 主播 uid
                mediaType: .audioOnly,  // mediaType: 订阅的数据类型
                view: nil,              // view: 视频数据渲染显示的视图
                renderMode: .hidden,    // renderMode: 视频数据渲染方式
                videoType: .high        // videoType: 大小流
            )
            //设置推流参数
            self.lock.lock()
            if(!users.contains(uid)){
                users.append(uid)
                self._updateTranscoding()
            }
            self.lock.unlock()
            QtNotice.shared.postEvent(QtAgoraEvent.AudienceConnected, userInfo: [QtAgoraEvent.AudienceUidKey: uid])
        }
        else if(delegate != nil){
            //如果不该连麦的人加入了channel，请求他退出
            publisher.sendUnpublishingRequest(toUid: uid)
            QtSwift.print("===== publisher.sendUnpublishingRequest(toUid: \(uid)) =====")
        }
    }
    
    // 频道内主播结束直播
    func subscriber(_ subscriber: AgoraLiveSubscriber, unpublishedByHostUid uid: UInt) {
        QtSwift.print("===== subscriber unpublishedByHostUid:\(uid) =====")
        subscriber.unsubscribe(toHostUid: uid)
        //设置推流参数
        self.lock.lock()
        if(users.contains(uid)){
            users.remove(at: users.index(of: uid)!)
            self._updateTranscoding()
        }
        self.lock.unlock()
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
    
    /**
     *  Statistics of rtc engine status. Updated every two seconds.
     *
     *  @param engine The engine kit
     *  @param stats  The statistics of rtc status, including duration, sent bytes and received bytes
     */
    var statsCount:Int = 60
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        if(statsCount >= 60){
            statsCount = 0
            let cpu_app = stats.cpuAppUsage
            let cpu_total = stats.cpuTotalUsage
            let rx_abr = stats.rxAudioKBitrate
            let rx_vbr = stats.rxVideoKBitrate
            let tx_abr = stats.txAudioKBitrate
            let tx_vbr = stats.txVideoKBitrate
            let du = stats.duration
            let usersFromStats = stats.userCount
            let usersFromQt = self.users.count
//            API.shared.sendBeacon(name: "hostinp", event: "engine_state", params:
//                ["cpu_app":"\(cpu_app)",
//                    "cpu_total":"\(cpu_total)",
//                    "rx_abr":"\(rx_abr)",
//                    "rx_vbr":"\(rx_vbr)",
//                    "tx_abr":"\(tx_abr)",
//                    "tx_vbr":"\(tx_vbr)",
//                    "du":"\(du)",
//                    "users":"\(usersFromStats)",
//                    "act_users":"\(usersFromQt)"], commonParams: self.commonBeacon)
        }
        else{
            statsCount += 1
        }
    }
}
