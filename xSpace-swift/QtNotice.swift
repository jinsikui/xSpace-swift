//
//  QtNotice.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/3.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class QtTimerContext {
    var curTime:Int = 0
    var intervalTime:Int = 1
    var action:(()->())?
    
    func timeTicking(){
        curTime += 1
        if (curTime >= intervalTime) {
            if(action != nil){
                action!()
            }
            curTime = 0
        }
    }
}

class QtNotice : NSObject {
    
    static let shared = QtNotice()
    
    let kAppFinishLaunching = "QtNotice.AppFinishLaunching"
    let kAppBecomeActive = "QtNotice.AppBecomeActive"
    let kAppEnterBackground = "QtNotice.AppEnterBackground"
    let kAppWillTerminate = "QtNotice.AppWillTerminate"
    let kAppWillResignActive = "QtNotice.AppWillResignActive"
    let kAppAudioSessionRouteChange = "QtNotice.AppAudioSessionRouteChange"
    let kTimerTicking = "QtNotice.TimerTicking"
    let kSignIn = "QtNotice.SignIn"
    var customEventNames = Array<String>()
    
    private var actionDic:Dictionary<String, NSMapTable<AnyObject, ObjectWrapper<(Any?)->()>>>!
    private var bindQueue:DispatchQueue!
    private var timer: QtTimer!
    private var timerTable:NSMapTable<AnyObject, QtTimerContext>!
    private var hasRegisttered = false
    private let _customEventNameKey = "QtNotice.customEventNameKey"
    private let _customEventUserInfoKey = "QtNotice.customEventUserInfoKey"
    
    private override init(){
        super.init()
        actionDic = Dictionary<String, NSMapTable<AnyObject, ObjectWrapper<(Any?)->()>>>()
        bindQueue = DispatchQueue(label:"QtNotice.bindQueue", attributes:.concurrent)
        timerTable = NSMapTable<AnyObject, QtTimerContext>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
        timer = QtTimer(interval: .seconds(1), queue: bindQueue, action: {[unowned self] in
            self.timerTicking()
        })
        registerNotices()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotices(){
        if(hasRegisttered){
            return
        }
        hasRegisttered = true
        NotificationCenter.default.addObserver(self, selector: #selector(appFinishLaunching), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appAudioSessionRouteChange), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(fireSignIn), name:NSNotification.Name(rawValue: self.kSignIn), object: nil)
    }
    
    private func setAction(_ actionKey:String, lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        var mapTable = actionDic[actionKey]
        if(mapTable == nil){
            mapTable = NSMapTable<AnyObject, ObjectWrapper<(Any?)->()>>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
            actionDic[actionKey] = mapTable
        }
        mapTable!.setObject(ObjectWrapper<(Any?)->()>(value:action), forKey: lifeIndicator)
    }
    
    private func runAction(key:String, param:Any?){
        let mapTable = actionDic[key]
        if (mapTable == nil) {
            return;
        }
        let enumerator = mapTable!.objectEnumerator()
        var obj = enumerator?.nextObject()
        while ( obj != nil) {
            (obj as! ObjectWrapper<(Any?)->()>).value(param)
            obj = enumerator?.nextObject()
        }
    }
    
    private func resumeTimer(){
        timer.start()
    }
    
    private func suspendTimer(){
        timer.stop()
    }
    
    //MARK: - Notification handlers
    
    @objc func appFinishLaunching(notification: NSNotification){
        bindQueue.async {
            self.runAction(key: self.kAppFinishLaunching, param: notification.userInfo)
        }
    }
    
    @objc func appBecomeActive(notification: NSNotification){
        bindQueue.async {
            self.resumeTimer()
            self.timerTicking()
            self.runAction(key: self.kAppBecomeActive, param: notification.userInfo)
        }
    }
    
    @objc func appWillResignActive(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: self.kAppWillResignActive, param: notification.userInfo)
        }
    }
    
    @objc func appAudioSessionRouteChange(notification: NSNotification){
        bindQueue.async {
            self.runAction(key: self.kAppAudioSessionRouteChange, param: notification.userInfo)
        }
    }
    
    @objc func appEnterBackground(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: self.kAppEnterBackground, param: notification.userInfo)
        }
    }
    
    @objc func appWillTerminate(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: self.kAppWillTerminate, param: notification.userInfo)
        }
    }
    
    func timerTicking(){
        let mapTable = actionDic[self.kTimerTicking];
        if (mapTable == nil || mapTable!.count <= 0) {
            self.suspendTimer()
            return;
        }
        self.runAction(key: self.kTimerTicking, param: nil)
    }
    
    @objc func fireSignIn(notification: NSNotification){
        bindQueue.async {
            self.runAction(key: self.kSignIn, param: notification.userInfo)
        }
    }
    
    @objc func customEventFired(notification:NSNotification){
        bindQueue.async {
            let eventName = notification.userInfo![self._customEventNameKey] as! String
            let userInfo = notification.userInfo![self._customEventUserInfoKey]
            self.runAction(key: eventName, param: userInfo)
        }
    }
    
    //MARK: - register methods
    
    func registerAppFinishLaunching(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppFinishLaunching, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppBecomeActive(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppBecomeActive, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppWillResignActive(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppWillResignActive, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppEnterBackground(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppEnterBackground, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppWillTerminate(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppWillTerminate, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppAudioSessionRouteChange(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kAppAudioSessionRouteChange, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    private func registerTimerTicking(lifeIndicator:AnyObject, action:@escaping (Any?)->()) {
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kTimerTicking, lifeIndicator: lifeIndicator, action: action)
            self.resumeTimer()
        })
    }
    
    func registerTimer(lifeIndicator:AnyObject, interval:Int, action:@escaping ()->()) {
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            let context = QtTimerContext()
            context.curTime = 0
            context.intervalTime = interval
            context.action = action
            self.timerTable.setObject(context, forKey: lifeIndicator)
            weak var weakContext = context
            self.registerTimerTicking(lifeIndicator: lifeIndicator, action: { (any) in
                weakContext?.timeTicking()
            })
        })
    }
    
    func registerSignIn(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(self.kSignIn, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerEvent(_ eventName:String, lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(eventName, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    //MARK: - Post Notice
    
    func postSignIn(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: self.kSignIn), object: nil, userInfo: nil))
    }
    
    
    func postEvent(_ eventName:String, userInfo:Dictionary<String, Any>?){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            if(!self.customEventNames.contains(eventName)){
                self.customEventNames.append(eventName)
                NotificationCenter.default.addObserver(self, selector: #selector(self.customEventFired(notification:)), name: Notification.Name(rawValue: eventName), object: nil)
            }
            var userInfoWrapper = Dictionary<String, Any>()
            userInfoWrapper[self._customEventNameKey] = eventName
            if(userInfo != nil){
                userInfoWrapper[self._customEventUserInfoKey] = userInfo!
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: eventName), object: nil, userInfo: userInfoWrapper))
        })
    }
}

