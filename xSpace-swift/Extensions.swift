//
//  Extensions.swift
//  xSpace-swift
//
//  Created by JSK on 2017/10/19.
//  Copyright © 2017年 JSK. All rights reserved.
//

import UIKit
import Foundation
import YYText

extension NSAttributedString {
    
    func qt_sizeWithMaxWidth(maxWidth:CGFloat) -> CGSize{
        let layout = YYTextLayout(containerSize: CGSize(width:maxWidth, height:CGFloat.greatestFiniteMagnitude), text: self)
        return layout!.textBoundingSize
    }
    
    func qt_heightWithMaxWidth(maxWidth:CGFloat) -> CGFloat{
        let size = self.qt_sizeWithMaxWidth(maxWidth: maxWidth)
        return size.height
    }
}

extension NSMutableAttributedString{
    
    @discardableResult func qt_appendImg(url:String, size:CGSize, alignTo font:UIFont) -> NSMutableAttributedString{
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = size
        imageView.af_setImage(withURL: URL(string:url)!)
        let imgAttr = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center, attachmentSize: size, alignTo: font, alignment: .center)
        self.append(imgAttr)
        return self
    }
    
    @discardableResult func qt_appendImg(named:String, alignTo font:UIFont) -> NSMutableAttributedString{
        let img = UIImage(named:named)!
        let imageView = UIImageView()
        imageView.image = img
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = img.size
        let imgAttr = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center, attachmentSize: img.size, alignTo: font, alignment: .center)
        self.append(imgAttr)
        return self
    }
    
    @discardableResult func qt_appendStr(_ str:String, foreColor:UIColor, font:UIFont) -> NSMutableAttributedString{
        let attr = NSMutableAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor: foreColor, NSAttributedStringKey.font: font])
        self.append(attr)
        return self
    }
}

extension String {
    
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}

extension UIImage {
    
    // 等比例缩小至指定宽度
    func compressToWidth(_ width:CGFloat) -> UIImage{
        if(self.size.width <= width){
            return self
        }
        let height = (self.size.height / self.size.width) * width
        return self.compressToDimension(CGSize(width:width, height:height))
    }
    
    // 缩小至指定宽高，比例不一致会裁剪
    func compressToDimension(_ size:CGSize) -> UIImage{
        var newImage:UIImage? = nil
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height
        var scaleFactor = CGFloat(0.0)
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x:0, y:0)
        if (!imageSize.equalTo(size))
        {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if (widthFactor > heightFactor){
                scaleFactor = widthFactor
            }
            else{
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            // center the image
            if (widthFactor > heightFactor)
            {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }
            else if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContextWithOptions(size, self.isOpaque, self.scale) // this will crop
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        self.draw(in:thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // size: kb，通过尝试找到最合适压缩质量，压缩有极限，如果图片过大不保证能压缩至指定size
    func compressToSize(_ size:Float) -> UIImage{
        let targetSize = size * 1024
        var f = 5, maxf = 10, minf = 0, sup = 100, inf = -100
        var find = false
        var imageData:NSData? = nil
        repeat{
            imageData = NSData(data: UIImageJPEGRepresentation(self, CGFloat(f)/10.0)!)
            if(Float(imageData!.length) < targetSize){
                inf = f
                if(f == maxf){
                    find = true
                }
                minf = f
                if(sup == f + 1){
                    find = true
                }
                f = Int(ceil(Float(f + maxf) * 0.5))
            }
            else if(Float(imageData!.length) > targetSize){
                sup = f
                if(f == minf){
                    find = true
                }
                maxf = f
                if(inf == f - 1){
                    f = inf
                    imageData = NSData(data: UIImageJPEGRepresentation(self, CGFloat(f)/10.0)!)
                    find = true
                }
                f = Int(floor(Float(f + minf) * 0.5))
            }
            else{
                find = true
            }
        } while !find
        
        return UIImage(data:imageData! as Data)!
    }
    
    // 按指定的质量压缩 quality:0.0(最大压缩)~1.0(不压缩)
    func compressToQuality(_ quality: Float) -> UIImage {
        let imageData = NSData(data: UIImageJPEGRepresentation(self, CGFloat(quality))!)
        return UIImage(data: imageData as Data)!
    }
    
    // 图片是否不透明
    var isOpaque: Bool { return !containsAlphaComponent }
    
    private var containsAlphaComponent: Bool {
        let alphaInfo = cgImage?.alphaInfo
        return (
            alphaInfo == .first ||
                alphaInfo == .last ||
                alphaInfo == .premultipliedFirst ||
                alphaInfo == .premultipliedLast
        )
    }
}

extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
