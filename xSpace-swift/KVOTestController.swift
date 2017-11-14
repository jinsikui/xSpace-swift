//
//  KVOTestController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/14.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import KVOController

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
    
    var clockList:Array<ClockModel> = Array<ClockModel>()
    var timer:QtTimer!
    let labelTag = 1000
    var tableView:QtGenericGridView!
    
    deinit{
        print("====== KVOTestController deinit ======")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = QtTimer(interval: .seconds(1)) {[unowned self] in
            for clock in self.clockList{
                clock.timeCount += 1
            }
        }
        timer.start()
        for i in 1...10{
            clockList.append(ClockModel(i))
        }
        let btn = QtViewFactory.button(text: "reload", font: QtFont.regularPF(14), textColor: QtColor.black, borderColor:QtColor.black, borderWidth:0.5)
        btn.addTarget(self, action: #selector(actionReload), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.left.equalTo(100)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        let tableView = QtGenericGridView(cellClass: ClockCell.self)
        self.tableView = tableView
        tableView.backgroundColor = QtColor.colorFromRGB(rgbValue: 0xEEEEEE)
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
    
    func actionReload(){
        var newArr = Array<ClockModel>()
        for i in 1000...1005{
            newArr.append(ClockModel(i))
        }
        self.clockList =  newArr
        self.tableView.dataList = newArr
        self.tableView.reloadData()
    }

}
