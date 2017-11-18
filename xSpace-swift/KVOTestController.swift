//
//  KVOTestController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/14.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import KVOController
import PKHUD

class ClockModel:NSObject{
    dynamic var timeCount:Int = 0
    
    init(_ timeCount:Int){
        super.init()
        self.timeCount = timeCount
    }
}

class ClockCell:UICollectionViewCell{
    var kvo:FBKVOController?
    var clock:ClockModel?
    var label:UILabel?
    var refreshCount = 0
    var cellId = "\(arc4random())"
    var kvoList = Array<FBKVOController>()
    
    func refresh(clock:ClockModel){
        refreshCount += 1
        if(label == nil){
            label = QtViewFactory.label(font: QtFont.regularPF(25), title: "", color: QtColor.black)
            label!.textAlignment = .left
            self.addSubview(label!)
            label!.snp.makeConstraints({ (make) in
                make.left.equalTo(20)
                make.top.bottom.right.equalTo(0)
            })
        }
        self.clock = clock
        self.kvo = nil   //释放之前的kvo
        self.kvo = FBKVOController(observer: self)
        let _refreshCount = self.refreshCount
        kvo!.observe(self.clock!, keyPath: "timeCount", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial]) {[unowned self] (cell, _clock, change) in
            DispatchQueue.main.async {
                //可以看到，同一个cell当refresh增加后，之前的refresh就不会print出来了，说明之前的handler被释放了
                print("===== cell:\(self.cellId) refreshCount:\(_refreshCount) timeCount:\(change["new"] as! Int) =====")
                self.label!.text = String(change["new"] as! Int)
            }
        }
    }
}

class KVOTestController: QtBaseViewController {
    dynamic var isOK = false
    dynamic var arr = [1,2]
    dynamic var arr2 = [ClockModel(1),ClockModel(2)]
    var clockList:Array<ClockModel> = Array<ClockModel>()
    var timer:QtTimer!
    let labelTag = 1000
    var tableView:QtGenericGridView!
    private var _count:Int = 0
    dynamic var count:Int{
        set{
            _count = newValue
        }
        get{
            return _count
        }
    }
    
    deinit{
        print("====== KVOTestController deinit ======")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kvoController.observe(self, keyPath: "count", options: [.new]) { (observer, object, change) in
            print("=== count change: \(self.count) ===")
        }
        self.kvoController.observe(self, keyPath: "isOK", options: [.initial, .new]) { (observer, object, change) in
            print("=== \(self.isOK) ===")
        }
        self.kvoController.observe(self, keyPath: "arr", options: [.initial, .new]) { (observer, object, change) in
            print("=== \(self.arr.count) ===")
        }
        self.kvoController.observe(self, keyPath: "arr2", options: [.initial, .new]) { (observer, object, change) in
            print("=== \(self.arr2.count) ===")
        }
        timer = QtTimer(interval: .seconds(1)) {[unowned self] in
            for clock in self.clockList{
                clock.timeCount += 1
            }
        }
        timer.start()
        for i in 1...10{
            clockList.append(ClockModel(i))
        }
        let btn = QtViewFactory.button(text: "change", font: QtFont.regularPF(14), textColor: QtColor.black, borderColor:QtColor.black, borderWidth:0.5)
        btn.addTarget(self, action: #selector(actionChange), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.left.equalTo(100)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        let tableView = QtGenericGridView(cellClass: ClockCell.self)
        self.tableView = tableView
        tableView.backgroundColor = QtColor.fromRGB(0xEEEEEE)
        tableView.scrollDirection = .vertical
        tableView.isScrollEnabled = true
        tableView.itemSize = CGSize(width:QtDevice.screenWidth, height:50)
        tableView.dataList = clockList
        tableView.buildCellCallback = { cell in
            (cell as! ClockCell).refresh(clock: cell.qt_data as! ClockModel)
        }
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(200)
            make.left.right.equalTo(0)
            make.height.equalTo(80)
        }
    }
    
    func actionChange(){
        self.count = 10
        self.isOK = !self.isOK
        //self.arr.append(1)  //will trigger
        //self.arr[0] = 10 //will trigger
        var _arr = self.arr
        _arr[0] = 10
        _arr.append(100) //will not trigger actually self.arr is not changed
        self.arr2[0].timeCount = 10 //will not trigger
        var newArr = Array<ClockModel>()
        for i in 1000...1005{
            newArr.append(ClockModel(i))
        }
        self.clockList =  newArr
        self.tableView.dataList = newArr
        self.tableView.reloadData()
    }

}
