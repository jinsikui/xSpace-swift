//
//  QtTimer.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/14.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class QtTimer: NSObject {
    private var timer: DispatchSourceTimer!
    private var queue:DispatchQueue!
    private var isTimerRunning = false
    private var action:(()->())!
    
    convenience init(interval:DispatchTimeInterval, action:@escaping ()->()){
        self.init(interval: interval, queue: DispatchQueue.global(), action: action)
    }
    
    init(interval:DispatchTimeInterval, queue:DispatchQueue, action:@escaping ()->()){
        super.init()
        self.queue = queue
        self.action = action
        let timer = DispatchSource.makeTimerSource(queue: queue)
        self.timer = timer
        timer.scheduleRepeating(deadline: .now(), interval: interval)
        timer.setEventHandler {[weak self] in
            self?.timerTicking()
        }
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        start()
        action = nil
    }
    
    func start(){
        if(isTimerRunning){
            return
        }
        isTimerRunning = true
        timer.resume()
    }
    
    func stop(){
        if(!isTimerRunning){
            return
        }
        isTimerRunning = false
        timer.suspend()
    }
    
    func timerTicking(){
        self.action()
    }
}
