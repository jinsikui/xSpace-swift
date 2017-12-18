import Foundation
import UIKit
import AlamofireImage
import YYText


public enum UIBorderSide {
    // Specify the boarders location at four sides
    case top, down, left, right
}

extension Array{
    func qt_prefixArrayOf(count:Int) -> Array{
        return self.enumerated().flatMap{ $0.offset < count ? $0.element : nil }
    }
    
    func qt_suffixArrayOf(count:Int) -> Array{
        return self.enumerated().flatMap{ $0.offset >= self.count - count ? $0.element : nil }
    }
}

extension UITableView{
    
    func scrollToTop(animated:Bool){
        if(self.numberOfRows(inSection: 0) > 0){
            self.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
        }
        else{
            self.scrollTo(offset: CGPoint(x:0, y:0), animated: animated)
        }
    }
    
    func scrollTo(offset:CGPoint, animated:Bool) {
        self.setContentOffset(offset, animated: animated)
    }
    
    func scrollToBottom(animated:Bool){
        let rowCount = self.numberOfRows(inSection: 0)
        if(rowCount > 0){
            if(rowCount >= 2){
                self.scrollToRow(at: IndexPath(row: rowCount - 2, section: 0), at: .bottom, animated: false)
            }
            self.scrollToRow(at: IndexPath(row: rowCount - 1, section: 0), at: .bottom, animated: animated)
        }
    }
}

extension UIView {
    func addBorder(side: UIBorderSide, color: UIColor, width: CGFloat, insetX: CGFloat=0.0, insetY: CGFloat=0.0) {
        // Add boarder to uiview by add sublayer to the layer
        let border = CALayer()
        border.borderColor = color.cgColor
        switch side {
        case .down:
            border.frame = CGRect(x: insetX, y: frame.size.height + insetY, width: frame.size.width - 2*insetX, height: width)
        case .top:
            // TODO: implement it yourself
            break
        case .left:
            border.frame = CGRect(x: insetX, y: insetY, width: width, height: frame.size.height - 2*insetY)
            break
        case .right:
            // TODO: implement it yourself
            break
        }
        border.borderWidth = width
        layer.addSublayer(border)
        border.masksToBounds = true
    }
}

extension String {
    
    func qt_sizeWithFont(_ font:UIFont, maxWidth:CGFloat) -> CGSize{
        let attr = NSAttributedString(string: self, attributes: [NSFontAttributeName: font])
        return attr.qt_sizeWithMaxWidth(maxWidth: maxWidth)
    }
    
    func qt_sizeWithFont(_ font:UIFont) -> CGSize{
        return self.qt_sizeWithFont(font, maxWidth: CGFloat.greatestFiniteMagnitude)
    }
}

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
        let attr = NSMutableAttributedString(string: str, attributes: [NSForegroundColorAttributeName: foreColor, NSFontAttributeName: font])
        self.append(attr)
        return self
    }
    
    static func qt_attrStrWith(str:String, foreColor:UIColor, font:UIFont) -> NSMutableAttributedString{
        let attr = NSMutableAttributedString(string: str, attributes: [NSForegroundColorAttributeName: foreColor, NSFontAttributeName: font])
        return attr
    }
}

extension String {
    
    func qt_subString(_ start:Int, len:Int) -> String{
        return self[self.index(self.startIndex, offsetBy:start) ..< self.index(self.startIndex, offsetBy:len)]
    }
    
    func toDate(format: String="yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: self)
        return date
    }
    
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

extension UIImageView {
    func showAvatar(urlString: String?, width: CGFloat) {
        let placeholder = UIImage(named: "avatarPlaceholder")?.af_imageRoundedIntoCircle()
        if let urlString = urlString, urlString.count > 0 {
            let url = URL(string: urlString)!
            let filter = AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: width/2)
            self.af_setImage(withURL: url, placeholderImage: placeholder, filter: filter)
        } else {
            image = placeholder
        }
    }
    
    func showCover(urlString: String?) {
        let placeholder = UIImage(named: "coverPlaceholder")
        if let urlString = urlString, urlString.count > 0 {
            let url = URL(string: urlString)!
            contentMode = .scaleAspectFill
            self.af_setImage(withURL: url, placeholderImage: placeholder)
            
        } else {
            image = placeholder
        }
    }
    func showImage(urlString: String?) {
        if let urlString = urlString, urlString.count > 0 {
            let url = URL(string: urlString)!
            self.af_setImage(withURL: url)
        }
    }
}

extension Date {
    func formatted(format: String="yyyy.MM.dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func UTC8Formatted(format: String="yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CT")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var isoString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
}

extension UIViewController {
    func presentAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    var containsAlphaComponent: Bool {
        let alphaInfo = cgImage?.alphaInfo
        return (
            alphaInfo == .first ||
            alphaInfo == .last ||
            alphaInfo == .premultipliedFirst ||
            alphaInfo == .premultipliedLast
        )
    }
    
    /// Returns whether the image is opaque.
    var isOpaque: Bool { return !containsAlphaComponent }
}

extension NSData {
    // size: kb
    func compressImageToSize(_ size: Float) -> UIImage? {
        let image = UIImage(data:self as Data)
        return image?.compressToSize(size)
    }
}
