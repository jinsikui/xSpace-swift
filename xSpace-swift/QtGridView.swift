//
//  QtGenericGridView.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/27.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

extension UICollectionViewCell{
    var qt_data:Any?{
        get {
            return objc_getAssociatedObject(self, UICollectionViewCellRuntimeKey.KEY_data!)
        }
        set {
            objc_setAssociatedObject(self, UICollectionViewCellRuntimeKey.KEY_data!, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var qt_indexPath:IndexPath?{
        get {
            guard let _indexPath = objc_getAssociatedObject(self, UICollectionViewCellRuntimeKey.KEY_indexPath!) as? IndexPath else {
                return nil
            }
            return _indexPath
        }
        set {
            objc_setAssociatedObject(self, UICollectionViewCellRuntimeKey.KEY_indexPath!, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

fileprivate struct UICollectionViewCellRuntimeKey {
    static let KEY_data = UnsafeRawPointer(bitPattern: "KEY_data".hashValue)
    static let KEY_indexPath = UnsafeRawPointer(bitPattern: "KEY_indexPath".hashValue)
}

class QtGridView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView:UICollectionView!
    private var layout:UICollectionViewFlowLayout!
    private let reuseId:String! = "\(arc4random())"
    private var _scrollEndCallback:((CGPoint)->())?
    private var _buildCellCallback:((UICollectionViewCell)->())?
    private var _itemSizeCallback:((Any,IndexPath)->CGSize)?
    private var _selectCellCallback:((UICollectionViewCell)->())?
    
    var cellClass:AnyClass! = UICollectionViewCell.self
    var dataList:Array<Any>?
    var bounce:Bool{
        set{
            collectionView.bounces = newValue
        }
        get{
            return collectionView.bounces
        }
    }
    var scrollDirection:UICollectionViewScrollDirection{
        set{
            layout.scrollDirection = newValue
        }
        get{
            return layout.scrollDirection
        }
    }
    var itemSize:CGSize{
        set{
            layout.itemSize = newValue
        }
        get{
            return layout.itemSize
        }
    }
    var lineSpace:CGFloat{
        set{
            layout.minimumLineSpacing = newValue
        }
        get{
            return layout.minimumLineSpacing
        }
    }
    var interitemSpace:CGFloat{
        set{
            layout.minimumInteritemSpacing = newValue
        }
        get{
            return layout.minimumInteritemSpacing
        }
    }
    var isScrollEnabled:Bool{
        set{
            collectionView.isScrollEnabled = newValue
            if(layout.scrollDirection == .vertical){
                collectionView.alwaysBounceVertical = newValue
            }
        }
        get{
            return collectionView.isScrollEnabled
        }
    }
    var contentInset:UIEdgeInsets{
        set{
            collectionView.contentInset = newValue
        }
        get{
            return collectionView.contentInset
        }
    }
    var isScrollToTop:Bool{
        set{
            collectionView.scrollsToTop = newValue
        }
        get{
            return collectionView.scrollsToTop
        }
    }
    var scrollEndCallback:((CGPoint)->())?{
        set{
            _scrollEndCallback = newValue
        }
        get{
            return _scrollEndCallback
        }
    }
    var buildCellCallback:((UICollectionViewCell)->())?{
        set{
            _buildCellCallback = newValue
        }
        get{
            return _buildCellCallback
        }
    }
    var itemSizeCallback:((Any,IndexPath)->CGSize)?{
        set{
            _itemSizeCallback = newValue
        }
        get{
            return _itemSizeCallback
        }
    }
    
    var selectCellCallback:((UICollectionViewCell)->())?{
        set{
            _selectCellCallback = newValue
        }
        get{
            return _selectCellCallback
        }
    }
    
    func cellWith(indexPath:IndexPath) -> UICollectionViewCell{
        return collectionView.cellForItem(at: indexPath)!
    }
    
    var numberOfSections: Int {
        get {
            return collectionView.numberOfSections
        }
    }
    
    func numberOfItems(inSection section: Int) -> Int{
        return collectionView.numberOfItems(inSection:section)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool){
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToTop(animated:Bool){
        if(self.numberOfItems(inSection: 0) > 0){
            self.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: animated)
        }
        else{
            self.scrollTo(offset: CGPoint(x:0, y:0), animated: animated)
        }
    }
    
    func scrollToBottom(animated:Bool){
        let rowCount = self.numberOfItems(inSection: 0)
        if(rowCount > 0){
            self.scrollToItem(at: IndexPath(row: rowCount - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: animated)
        }
    }
    
    func scrollTo(offset:CGPoint, animated:Bool) {
        collectionView.setContentOffset(offset, animated: animated)
    }
    
    init(cellClass:AnyClass){
        super.init(frame: CGRect.zero)
        self.cellClass = cellClass
        self.prepare()
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }
    
    func prepare(){
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = QtColor.clear
        self.backgroundColor = QtColor.clear
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        collectionView.register(self.cellClass, forCellWithReuseIdentifier: self.reuseId)
    }
    
    //MARK: - UIScrollViewDelegate
    
    /** 滚动结束后调用（代码导致） */
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if(self.scrollEndCallback != nil){
            self.scrollEndCallback!(collectionView.contentOffset)
        }
    }
    /** 滚动结束（手势导致） */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
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
        if(_itemSizeCallback != nil){
            return _itemSizeCallback!(dataList![indexPath.item], indexPath)
        }
        return layout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseId, for: indexPath)
        cell.qt_indexPath = indexPath
        cell.qt_data = dataList![indexPath.item]
        if(self.buildCellCallback != nil){
            self.buildCellCallback!(cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        if(self.selectCellCallback != nil){
            self.selectCellCallback!(cell)
        }
    }
}


