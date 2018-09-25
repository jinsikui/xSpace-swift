//
//  QtTask.swift
//  LiveAssistant
//
//  Created by JSK on 2017/12/1.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import KVOController

class QtTaskStatus{
    static let initial:String = "QtTaskStatus.initial"
    static let executing:String = "QtTaskStatus.executing"
    static let canceled:String = "QtTaskStatus.canceled"
    static let completed:String = "QtTaskStatus.completed"
}

class QtTaskHandle: NSObject{
    dynamic var status:String = QtTaskStatus.initial
    var result:Any? //任务执行结果，可选设置
    var error:Error? //对于异常结束的任务，可以在这里设置错误信息
    
    //这里只cancel未执行的任务
    //更规范的做法是调用task的cancel方法，那里允许在一些情况下cancel正在excuting的任务
    func cancel(){
        if status == QtTaskStatus.initial{
            status = QtTaskStatus.canceled
        }
    }
}

protocol QtTaskProtocol{
    var handle:QtTaskHandle { get }
    var status:String { get }
    func exec()
    func cancel() //cancel请求，不一定成功，调用后通过status查看是否cancel成功
}

class QtAsyncTask:NSObject,QtTaskProtocol{
    private var _handle:QtTaskHandle!
    var handle: QtTaskHandle{
        get{
            return _handle
        }
    }
    var status: String{
        get{
            return _handle.status
        }
    }
    var queue:DispatchQueue!
    var after:DispatchTimeInterval!
    var wrapperTask:(()->())!
    
    init(queue:DispatchQueue, after:DispatchTimeInterval, task:@escaping ()->()){
        super.init()
        self.queue = queue
        self.after = after
        let handle = QtTaskHandle()
        let wrapperTask = {
            if handle.status == QtTaskStatus.initial {
                handle.status = QtTaskStatus.executing
                task()
                handle.status = QtTaskStatus.completed
            }
        }
        self._handle = handle
        self.wrapperTask = wrapperTask
    }
    
    func exec(){
        if self.handle.status == QtTaskStatus.initial {
            if self.after == .seconds(0){
                queue.async(execute: self.wrapperTask)
            }
            else{
                queue.asyncAfter(deadline: DispatchTime.now() + self.after, execute: self.wrapperTask)
            }
        }
    }
    
    func cancel(){
        if status == QtTaskStatus.initial{
            _handle.status = QtTaskStatus.canceled
        }
    }
}

class QtCustomTask:NSObject, QtTaskProtocol{
    private var _handle:QtTaskHandle!
    var handle: QtTaskHandle{
        get{
            return _handle
        }
    }
    var status: String{
        get{
            return _handle.status
        }
    }
    var task:((QtTaskHandle)->())!
    
    init(_ task:@escaping (QtTaskHandle)->()){
        super.init()
        self.task = task
        self._handle = QtTaskHandle()
    }
    
    func exec() {
        self.task(_handle)
    }
    
    func cancel() {
        //customTask的cancel逻辑建议在传入的task中处理
    }
}

class QtDelayTask:NSObject, QtTaskProtocol{
    private var _handle:QtTaskHandle!
    var handle: QtTaskHandle{
        get{
            return _handle
        }
    }
    var status: String{
        get{
            return _handle.status
        }
    }
    var delay:DispatchTimeInterval!
    
    init(_ delay:DispatchTimeInterval){
        super.init()
        self.delay = delay
        self._handle = QtTaskHandle()
    }
    
    func exec() {
        if _handle.status == QtTaskStatus.initial {
            _handle.status = QtTaskStatus.executing
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + self.delay, execute: {[weak self] in
                if(self?._handle.status == QtTaskStatus.executing){
                    self?._handle.status = QtTaskStatus.completed
                }
            })
        }
    }
    
    func cancel(){
        if status == QtTaskStatus.initial || status == QtTaskStatus.executing{
            _handle.status = QtTaskStatus.canceled
        }
    }
}

enum QtCompositeTaskType{
    case all
    case any
}

//需要特别注意的是在函数中创建QtCompositeTask实例后应该用一个成员变量来保存
//否则函数执行完后QtCompositeTask实例被回收，就无法等到子任务完成触发回调了
class QtCompositeTask : NSObject, QtTaskProtocol {
    private var _handle:QtTaskHandle!
    var handle: QtTaskHandle{
        get{
            return _handle
        }
    }
    var status: String{
        get{
            return _handle.status
        }
    }
    var type:QtCompositeTaskType!
    var tasks:[QtTaskProtocol]!
    var callback:(([QtTaskProtocol])->())!
    var kvo:FBKVOController?
    
    init(type:QtCompositeTaskType, tasks:[QtTaskProtocol], callback:@escaping ([QtTaskProtocol])->()){
        super.init()
        self.type = type
        self.tasks = tasks
        self._handle = QtTaskHandle()
        self.callback = callback
    }
    
    deinit {
        print("===== QtCompositeTask deinit =====")
        self.kvo = nil
    }
    
    func determineComplete()->Bool{
        if type == .any {
            for task in tasks{
                if task.handle.status == QtTaskStatus.canceled || task.handle.status == QtTaskStatus.completed{
                    return true
                }
            }
            return false
        }
        else{
            for task in tasks{
                if task.handle.status != QtTaskStatus.canceled && task.handle.status != QtTaskStatus.completed{
                    return false
                }
            }
            return true
        }
    }
    
    func handleTaskStatusChanged(){
        let complete = self.determineComplete()
        if complete {
            self.kvo = nil
            if self._handle.status == QtTaskStatus.executing {
                self._handle.status = QtTaskStatus.completed
                self.callback(self.tasks)
            }
        }
    }
    
    func exec() {
        if status == QtTaskStatus.initial {
            _handle.status = QtTaskStatus.executing
            self.kvo = FBKVOController(observer: self)
            for task in tasks{
                task.exec()
                self.kvo?.observe(task, keyPath: "handle.status", options: [.initial, .new]) {[weak self] (observer, model, change) in
                    self?.handleTaskStatusChanged()
                }
            }
        }
    }
    
    func cancel(){
        if status == QtTaskStatus.initial || status == QtTaskStatus.executing{
            _handle.status = QtTaskStatus.canceled
        }
    }
}

class QtTask: NSObject {
    
    static func asyncMain(_ task:@escaping ()->()){
        return self.async(queue: DispatchQueue.main, task: task)
    }
    
    static func asyncGlobal(_ task:@escaping ()->()){
        return self.async(queue: DispatchQueue.global(), task: task)
    }
    
    static func async(queue:DispatchQueue, task:@escaping ()->()){
        let task = asyncTask(queue: queue, task: task)
        task.exec()
    }
    
    @discardableResult static func asyncMain(afterSecs:Int, task:@escaping ()->()) -> QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: DispatchQueue.main, task: task)
    }
    
    @discardableResult static func asyncGlobal(afterSecs:Int, task:@escaping ()->()) -> QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: DispatchQueue.global(), task: task)
    }
    
    @discardableResult static func async(afterSecs:Int, queue:DispatchQueue, task:@escaping ()->()) -> QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: queue, task: task)
    }
    
    @discardableResult static func asyncMain(after:DispatchTimeInterval, task:@escaping ()->()) -> QtTaskHandle{
        return QtTask.async(after: after, queue: DispatchQueue.main, task: task)
    }
    
    @discardableResult static func asyncGlobal(after:DispatchTimeInterval, task:@escaping ()->()) -> QtTaskHandle{
        return QtTask.async(after: after, queue: DispatchQueue.global(), task: task)
    }
    
    @discardableResult static func async(after:DispatchTimeInterval, queue:DispatchQueue, task:@escaping ()->()) -> QtTaskHandle{
        let task = self.asyncTask(after: after, queue: queue, task: task)
        task.exec()
        return task.handle
    }
    
    static func asyncTask(queue:DispatchQueue, task:@escaping ()->()) -> QtAsyncTask{
        return QtAsyncTask(queue: queue, after: .seconds(0), task: task)
    }
    
    static func asyncTask(after:DispatchTimeInterval, queue:DispatchQueue, task:@escaping ()->()) -> QtAsyncTask{
        return QtAsyncTask(queue: queue, after: after, task: task)
    }
    
    static func delayTask(_ delay:DispatchTimeInterval) -> QtDelayTask{
        return QtDelayTask(delay)
    }
    
    static func all(_ tasks:[QtTaskProtocol], callback:@escaping ([QtTaskProtocol])->()) -> QtCompositeTask{
        let compositTask = QtCompositeTask(type: .all, tasks: tasks, callback: callback)
        compositTask.exec()
        return compositTask
    }
    
    static func any(_ tasks:[QtTaskProtocol], callback:@escaping ([QtTaskProtocol])->()) -> QtCompositeTask{
        let compositTask = QtCompositeTask(type: .any, tasks: tasks, callback: callback)
        compositTask.exec()
        return compositTask
    }
}
