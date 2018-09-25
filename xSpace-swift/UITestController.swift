//
//  UITestController.swift
//  xSpace-swift
//
//  Created by JSK on 2018/1/4.
//  Copyright © 2018年 JSK. All rights reserved.
//

import UIKit
import MJRefresh
import KVOController
import Promises

class ViewModel:NSObject{
    dynamic var rowCount = 5
    dynamic var isPagesEnd = false
}

class UITestController: QtBaseViewController, UITableViewDelegate, UITableViewDataSource {

    var lifeVC:TestLiveCycleController?
    var gridView:UITableView?
    private let reuseId:String! = "\(arc4random())"
    var viewModel:ViewModel = ViewModel()
    var kvo:FBKVOController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sw = QtSwitch(title:"公告")
        self.view.addSubview(sw)
        sw.snp.makeConstraints { (make) in
            make.left.top.equalTo(100)
            make.width.equalTo(sw.outSize.width)
            make.height.equalTo(sw.outSize.height)
        }
        sw.actionHandler = {(isOn) in
            print("===== isOn:\(isOn) =====")
        }
        //
        let red = RedEntryView(count:3)
        self.view.addSubview(red)
        red.snp.makeConstraints { (make) in
            make.left.top.equalTo(200)
            make.width.equalTo(80)
            make.height.equalTo(130)
        }
        //
        
        
        //
        let grid = UITableView()
        grid.separatorStyle = .none
        grid.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseId)
        grid.delegate = self
        grid.dataSource = self
        self.gridView = grid
        self.view.addSubview(grid)
        grid.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(300)
        }
        grid.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {[weak self] in
            QtTask.asyncMain(after: .seconds(3), task: {
                if let grid = self?.gridView, let footer = grid.mj_footer{
                    self?.viewModel.rowCount = 10
                    self?.viewModel.isPagesEnd = true
                    footer.endRefreshing()
                }
            })
        })
        if let footer = grid.mj_footer as? MJRefreshBackNormalFooter{
            footer.setTitle("加载下一页", for: .idle)
            footer.setTitle("松手加载下一页", for: .pulling)
            footer.setTitle("即将加载...", for: .willRefresh)
            footer.setTitle("正在加载...", for: .refreshing)
            footer.setTitle("没有更多数据", for: .noMoreData)
        }
        
        let kvo = FBKVOController(observer: self)
        self.kvo = kvo
        kvo.observe(self.viewModel, keyPath: "rowCount", options: [.new], block: { [weak self] (observer, obj, change) in
            DispatchQueue.main.async {
                if let grid = self?.gridView {
                    grid.reloadData()
                }
            }
        })
        kvo.observe(self.viewModel, keyPath: "isPagesEnd", options: [.new], block: { [weak self] (observer, obj, change) in
            DispatchQueue.main.async {
                if let grid = self?.gridView, let footer = grid.mj_footer, let isPageEnd = self?.viewModel.isPagesEnd {
                    if isPageEnd {
                        footer.endRefreshingWithNoMoreData()
                    }
                    else {
                        footer.resetNoMoreData()
                    }
                }
            }
        })
        
        //test lifeCycle
        self.lifeVC = TestLiveCycleController()
    }
    
    //MARK: - UITableViewDataSource & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseId, for: indexPath)
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = QtColor.red
        }
        else{
            cell.backgroundColor = QtColor.green
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.5
    }

}
