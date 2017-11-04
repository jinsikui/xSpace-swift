//
//  QtNotice.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/3.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

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
    
    static let kAppFinishLaunching = "kAppFinishLaunching"
    static let kAppBecomeActive = "kAppBecomeActive"
    static let kAppEnterBackground = "kAppEnterBackground"
    static let kAppWillTerminate = "kAppWillTerminate"
    static let kAppWillResignActive = "kAppWillResignActive"
    static let kTimerTicking = "kTimerTicking"
    static let kSignIn = "kSignIn"
    
    private var actionDic:Dictionary<String, NSMapTable<AnyObject, ObjectWrapper<(Any?)->()>>>!
    private var bindQueue:DispatchQueue!
    private var timer: DispatchSourceTimer!
    private var timerTable:NSMapTable<AnyObject, QtTimerContext>!
    private var isTimerRunning = false
    private var hasRegisttered = false
    
    private override init(){
        super.init()
        actionDic = Dictionary<String, NSMapTable<AnyObject, ObjectWrapper<(Any?)->()>>>()
        bindQueue = DispatchQueue(label:"QtNotice.bindQueue", attributes:.concurrent)
        timerTable = NSMapTable<AnyObject, QtTimerContext>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
        timer = DispatchSource.makeTimerSource(queue: bindQueue)
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler {
            self.timerTicking()
        }
        registerNotices()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        timer.cancel()
        timer = nil
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
        //
        NotificationCenter.default.addObserver(self, selector: #selector(fireSignIn), name:NSNotification.Name(rawValue: QtNotice.kSignIn), object: nil)
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
        if(isTimerRunning){
            return
        }
        isTimerRunning = true
        timer.resume()
    }
    
    private func suspendTimer(){
        if(!isTimerRunning){
            return
        }
        isTimerRunning = false
        timer.suspend()
    }
    
    //MARK: - Notification handlers
    
    @objc func appFinishLaunching(notification: NSNotification){
        bindQueue.async {
            self.runAction(key: QtNotice.kAppFinishLaunching, param: notification.userInfo)
        }
    }
    
    @objc func appBecomeActive(notification: NSNotification){
        bindQueue.async {
            self.resumeTimer()
            self.timerTicking()
            self.runAction(key: QtNotice.kAppBecomeActive, param: notification.userInfo)
        }
    }
    
    @objc func appWillResignActive(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: QtNotice.kAppWillResignActive, param: notification.userInfo)
        }
    }
    
    @objc func appEnterBackground(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: QtNotice.kAppEnterBackground, param: notification.userInfo)
        }
    }
    
    @objc func appWillTerminate(notification: NSNotification){
        bindQueue.async {
            self.suspendTimer()
            self.runAction(key: QtNotice.kAppWillTerminate, param: notification.userInfo)
        }
    }
    
    func timerTicking(){
        let mapTable = actionDic[QtNotice.kTimerTicking];
        if (mapTable == nil || mapTable!.count <= 0) {
            self.suspendTimer()
            return;
        }
        self.runAction(key: QtNotice.kTimerTicking, param: nil)
    }
    
    @objc func fireSignIn(notification: NSNotification){
        bindQueue.async {
            self.runAction(key: QtNotice.kSignIn, param: notification.userInfo)
        }
    }
    
    //MARK: - register methods
    
    func registerAppFinishLaunching(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kAppFinishLaunching, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppBecomeActive(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kAppBecomeActive, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppWillResignActive(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kAppWillResignActive, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppEnterBackground(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kAppEnterBackground, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    func registerAppWillTerminate(lifeIndicator:AnyObject, action:@escaping (Any?)->()){
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kAppWillTerminate, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    private func registerTimerTicking(lifeIndicator:AnyObject, action:@escaping (Any?)->()) {
        bindQueue.async(execute: DispatchWorkItem(flags: .barrier) {
            self.setAction(QtNotice.kTimerTicking, lifeIndicator: lifeIndicator, action: action)
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
            self.setAction(QtNotice.kSignIn, lifeIndicator: lifeIndicator, action: action)
        })
    }
    
    //MARK: - Post Notice
    
    func postSignIn(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: QtNotice.kSignIn), object: nil, userInfo: nil))
    }
}
