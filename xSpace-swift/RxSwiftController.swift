//
//  RxSwiftController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/12/18.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import RxSwift

class MyMsg:ObservableConvertibleType{
    typealias E = String
    
    var msg:String
    var shouldDispose:Bool = false
    
    init(_ msg:String){
        self.msg = msg
    }
    
    func asObservable() -> Observable<String> {
        return Observable.create({ (observer) -> Disposable in
            if(!self.shouldDispose){
                observer.onNext("\(self.msg) aaa")
            }
            if(!self.shouldDispose){
                observer.onNext("\(self.msg) bbb")
            }
            if(!self.shouldDispose){
                observer.onNext("\(self.msg) ccc")
            }
            //observer.onError(NSError())
            observer.onCompleted()
            return Disposables.create {
                print("===== should dispose MyMsg \(self.msg) =====")
                self.shouldDispose = true
            }
        })
    }
}

class EventGenerator:NSObject{
    var subject:PublishSubject<String> = PublishSubject<String>()
    
    func sendMsg(){
        _ = QtTask.asyncGlobal(after: .seconds(3)) {[weak self] in
            self?.subject.onNext("hello subject")
            //self?.subject.onCompleted()
            _ = QtTask.asyncGlobal(after: .seconds(3), task: {[weak self] in
                self?.subject.onNext("hello subject again")
            })
        }
    }
    
    deinit {
        print("===== EventGenerator deinit =====")
    }
}

class RxSwiftController: QtBaseViewController {
    
    var obs:Observable<String>? = nil
    var eventGen:EventGenerator = EventGenerator()
    var disposeBag1:DisposeBag? = DisposeBag()
    var disposeBag2:DisposeBag? = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        //=================== test flatMap ======================
//        self.obs = self.createObservable().flatMap { (msg) -> MyMsg in
//            return MyMsg(msg)
//        }
//        .subscribeOn(MainScheduler.instance)
//        .observeOn(MainScheduler.instance)
//        _ = obs!.subscribe(
//            onNext: { (msg) in
//                print(msg)
//            },
//            onError: { (error) in
//                print("===== error =====")
//            })
        
        //=================== test subject ======================
        self.eventGen.subject.subscribe({ [weak self] (event) in
            self?.myPrint("===== subscribe 1 event fired. isCompleted:\(event.isCompleted) isStopEvent:\(event.isStopEvent) element:\(String(describing: event.element)) error:\(String(describing: event.error)) \ndesc:\(event.debugDescription) =====")
        }).disposed(by: self.disposeBag1!)
        self.eventGen.subject.subscribe({ [weak self] (event) in
            self?.myPrint("===== subscribe 2 event fired. isCompleted:\(event.isCompleted) isStopEvent:\(event.isStopEvent) element:\(String(describing: event.element)) error:\(String(describing: event.error)) \ndesc:\(event.debugDescription) =====")
        }).disposed(by: self.disposeBag2!)
        
        _ = QtTask.asyncGlobal(afterSecs: 10) {[weak self] in
            print("===== will fire event now =====")
            self?.eventGen.sendMsg()
        }
        _ = QtTask.asyncGlobal(afterSecs: 5) {[weak self] in
            self?.disposeBag1 = nil
            print("===== disposeBag1 set to nil =====")
        }
    }
    
    deinit {
        print("===== RxSwiftController deinit =====")
    }
    
    func myPrint(_ str:String){
        print(str)
    }
    
    func createObservable() -> Observable<String>{
        return Observable.create({ (observer) -> Disposable in
            _ = QtTask .asyncGlobal(after: .seconds(5), task: {
                observer.onNext("next 1")
                _ = QtTask.asyncGlobal(after: .seconds(3), task: {
                    observer.onNext("next 2")
                    observer.onNext("next 3")
                    observer.onCompleted()
                })
            })
            return Disposables.create {
                print("===== should dispose the observable =====")
            }
        })
    }
}
