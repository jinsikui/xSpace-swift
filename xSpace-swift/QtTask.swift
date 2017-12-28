//
//  QtTask.swift
//  LiveAssistant
//
//  Created by JSK on 2017/12/1.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit

class QtTaskHandle: NSObject{
    var isCanceled = false
    var isCompleted = false
    
    func cancel(){
        isCanceled = true
    }
}

class QtTask: NSObject {

    static func asyncMain(_ task:@escaping ()->()){
        DispatchQueue.main.async(execute: task)
    }
    
    static func asyncGlobal(_ task:@escaping ()->()){
        DispatchQueue.global().async(execute: task)
    }
    
    static func async(queue:DispatchQueue, task:@escaping ()->()){
        queue.async(execute: task)
    }
    
    static func asyncMain(afterSecs:Int, task:@escaping ()->())->QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: DispatchQueue.main, task: task)
    }
    
    static func asyncGlobal(afterSecs:Int, task:@escaping ()->())->QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: DispatchQueue.global(), task: task)
    }
    
    static func async(afterSecs:Int, queue:DispatchQueue, task:@escaping ()->())->QtTaskHandle{
        return QtTask.async(after: .seconds(afterSecs), queue: queue, task: task)
    }
    
    static func asyncMain(after:DispatchTimeInterval, task:@escaping ()->())->QtTaskHandle{
        return QtTask.async(after: after, queue: DispatchQueue.main, task: task)
    }
    
    static func asyncGlobal(after:DispatchTimeInterval, task:@escaping ()->())->QtTaskHandle{
        return QtTask.async(after: after, queue: DispatchQueue.global(), task: task)
    }
    
    static func async(after:DispatchTimeInterval, queue:DispatchQueue, task:@escaping ()->())->QtTaskHandle{
        let handle = QtTaskHandle()
        let _task = {
            if(handle.isCanceled){
                return
            }
            task()
            handle.isCompleted = true
        }
        queue.asyncAfter(deadline: DispatchTime.now()+after, execute: _task)
        return handle
    }
}
