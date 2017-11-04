//
//  GridViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/11/4.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class GridViewController: QtBaseViewController {
    
    deinit {
        print("===== GridViewController deinit =====")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QtGenericGridView"
        //
        let data1 = ["abc", "abcde", "abcdefghijklmnopq", "qq"]
        let grid1 = QtGenericGridView()
        grid1.scrollDirection = .horizontal
        grid1.isScrollEnabled = true
        grid1.dataList = data1
        let labelTag = 1000
        grid1.buildCellCallback = { cell in
            let str = cell.qt_data as! String
            var label = cell.viewWithTag(labelTag) as? UILabel
            if(label == nil){
                //
                cell.clipsToBounds = true
                label = QtViewFactory.label(font: QtFont.regularPF(12), title: "", color: QtColor.black)
                label!.tag = labelTag
                cell.addSubview(label!)
                label!.snp.makeConstraints({ (make) in
                    make.center.equalTo(cell.snp.center)
                })
            }
            label!.text = str
            label!.sizeToFit()
        }
        //固定cell尺寸
        //grid1.itemSize = CGSize(width:80, height:32)
        //不固定cell尺寸
        grid1.itemSizeCallback = { (data, indexPath) in
            let str = data as! String
            let label = QtViewFactory.label(font: QtFont.regularPF(12), title: str, color: QtColor.black)
            label.sizeToFit()
            return CGSize(width:label.frame.width + 10, height:32)
        }
        self.view.addSubview(grid1)
        grid1.snp.makeConstraints { (make) in
            make.top.equalTo(100)
            make.centerX.equalTo(self.view)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
        
        //
        let data2 = [20,30,40,20]
        let grid2 = QtGenericGridView()
        grid2.scrollDirection = .vertical
        grid2.isScrollEnabled = true
        grid2.dataList = data2
        grid2.buildCellCallback = { [weak self] cell in
            let row = cell.qt_indexPath!.row
            switch row{
            case 0:
                cell.backgroundColor = QtColor.gray
            case 1:
                cell.backgroundColor = QtColor.red
            case 2:
                cell.backgroundColor = QtColor.green
            case 3:
                cell.backgroundColor = QtColor.blue
            default:
                break
            }
            //self must be weak reference
            self?.call()
        }
        grid2.itemSizeCallback = { (data, indexPath) in
            return CGSize(width:200, height:(data as! Int))
        }
        self.view.addSubview(grid2)
        grid2.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(grid1.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(110)
        }
    }
    
    func call(){
        print("call")
    }
}
