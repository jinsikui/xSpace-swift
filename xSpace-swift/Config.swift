//
//  Config.swift
//  LiveAssistant
//
//  Created by JSK on 2017/11/3.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

class Config: NSObject {
    
    static var shared = Config()
    
    private let levelColorsFileName = "levelColors"
    private var _isInReview:Bool? = nil
    private let disposeBag = DisposeBag()
    
    var isInReview:Bool?{
        get {
            return _isInReview
        }
        set {
            _isInReview = newValue
        }
    }
    
    private override init(){
        super.init()
    }
    
    func getLoadedLevelColors() -> JSON?{
        return QtFile.shared.getFromDocument(filename: self.levelColorsFileName)
    }
    
    func loadLevelColors(){
        API.shared.getLevelColor().subscribe(onNext: { (r, json) in
                if let json = json as? JSON{
                    QtFile.shared.saveToDocument(filename: self.levelColorsFileName, json: json)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func testIfInReview(){
        API.shared.getOnlineAppInfo().subscribe(onNext: { (r, json) in
            if let json = json as? JSON, let results = json["results"].array, results.count > 0, let versionOnline = results[0]["version"].string {
                let version = QtDevice.appVersion
                let arrOnline = versionOnline.components(separatedBy: ".")
                let arr = version.components(separatedBy: ".")
                var i = 0
                var isInReview = false
                while i < arrOnline.count && i <= arr.count {
                    if let numOnline = Int(arrOnline[i]), let num = Int(arr[i]){
                        if numOnline < num {
                            isInReview = true
                            break
                        }
                        else if numOnline > num {
                            isInReview = false
                            break
                        }
                    }
                    i += 1
                }
                Config.shared.isInReview = isInReview
            }
        }).disposed(by: disposeBag)
    }
}
