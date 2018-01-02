//
//  CollectionViewController.swift
//  xSpace-swift
//
//  Created by JSK on 2017/12/29.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit

class CollectionViewController: QtBaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView:UICollectionView!
    private var layout:UICollectionViewFlowLayout!
    private let reuseId:String! = "\(arc4random())"
    var cellClass:AnyClass! = UICollectionViewCell.self
    var dataList:[Any]? = [1,2,3,4,5,6,7,8,9,10]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CollectionView test"
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = QtColor.fromRGB(0xEEEEEE)
        self.view.backgroundColor = QtColor.white
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.width.equalTo(330)
            make.height.equalTo(500)
        }
        collectionView.register(self.cellClass, forCellWithReuseIdentifier: self.reuseId)
    }
    
    //MARK: - UICollectionViewDelegate & DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(dataList == nil){
            return 0
        }
        return dataList!.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return layout.itemSize
    }
    
    var labelTag = 1000
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseId, for: indexPath)
        cell.qt_indexPath = indexPath
        cell.qt_data = dataList![indexPath.item]
        var label:UILabel? = cell.viewWithTag(labelTag) as? UILabel
        if(label == nil){
            label = QtViewFactory.label(font: QtFont.regularPF(15), title: "", color: QtColor.blue)
            cell.addSubview(label!)
            label?.snp.makeConstraints({ (make) in
                make.left.right.top.bottom.equalTo(0)
            })
            cell.layer.borderColor = QtColor.blue.cgColor
            cell.layer.borderWidth = 0.5
        }
        label?.text = "\(dataList![indexPath.item])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
    }
}
