//
//  HFFunction.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/5/17.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import SnapKit

enum ProjectType {
    case 琴家曲谱馆
    case 蔚科智能钢琴
}


class HFFunction: NSObject {

}
var 是iPhone = OCFunction.checkDevice()


func 变为竖屏()  {
    let number = NSNumber(value: UIInterfaceOrientation.unknown.rawValue)
    UIDevice.current.setValue(number, forKey: "orientation")
    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
}
func 变为横屏(){
    let number = NSNumber(value: UIInterfaceOrientation.unknown.rawValue)
    UIDevice.current.setValue(number, forKey: "orientation")
    if UIApplication.shared.statusBarOrientation == .landscapeRight {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }else{
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}


func getScale(y : CGFloat) -> CGFloat{
    return y / 768 * getHeith()
}
func scalefor(y: CGFloat) -> CGFloat {
    return y / getHeith() * 768
}
func getScale(x : CGFloat) -> CGFloat{
    return x / 1024 * getWIDTH()
}
func scalefor(x: CGFloat) -> CGFloat {
    return x / getWIDTH() * 1024
}

/// iPhone
func psx(_ x : CGFloat) -> CGFloat{
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
        return x / 375 * getWIDTH()
    }else{
        return x / 667 * getWIDTH()
    }
}
func psxy(x : CGFloat ,y : CGFloat) -> CGFloat{
    return psx( x) / x * y
}
func psxy(y : CGFloat) -> CGFloat {
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
       return getWIDTH() / 375 * y
    }else{
        return getWIDTH() / 667 * y
    }
}
/// 纵坐标按比例
func psy(y:CGFloat) -> CGFloat {
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
        return y / 667 * getHeith()
    }else{
        return y / 375 * getHeith()
    }
}
/////
//func psyx(x:CGFloat,y:CGFloat)->CGFloat{
//    if <#condition#> {
//        <#code#>
//    }
//    return psy(y: y) / y * x
//}
func psyx(x:CGFloat)->CGFloat{
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
        return getHeith() / 667 * x
    }else{
        return getHeith() / 375 * x
    }
}
///

extension CGRect {
    /// iPad 坐标和屏幕尺寸放缩
    init(scaleX : CGFloat,scaleY : CGFloat ,scaleW : CGFloat ,scaleH : CGFloat) {
        self.origin = CGPoint(x: scaleX / 1024 * getWIDTH(), y: scaleY / 768 * getHeith())
        self.size = CGSize(width: scaleW / 1024 * getWIDTH(), height: scaleH / 768 * getHeith())
    }
    /// iPad 横坐标放缩 纵坐标不变
    init(scaleX : CGFloat,Y : CGFloat ,scaleW : CGFloat ,H : CGFloat) {
        self.origin = CGPoint(x: scaleX / 1024 * getWIDTH(), y: Y)
        self.size = CGSize(width: scaleW / 1024 * getWIDTH(), height: H)
    }
    /// iPad
    init(X : CGFloat,scaleY : CGFloat ,W : CGFloat ,scaleH : CGFloat) {
        self.origin = CGPoint(x: X / 1024 * getWIDTH(), y: scaleY / 768 * getHeith())
        self.size = CGSize(width: W / 1024 * getWIDTH(), height: scaleH / 768 * getHeith())
    }
    /// iPhone 宽高按屏幕放缩
    init(psX : CGFloat,psY : CGFloat ,psW : CGFloat ,psH : CGFloat) {
        self.origin = CGPoint(x: psX / 375 * getWIDTH(), y: psY / 667 * getHeith())
        self.size = CGSize(width: psW / 375 * getWIDTH(), height: psH / 667 * getHeith())
    }
    /// iPhone 宽度按屏幕宽度 高度固定
    init(psX : CGFloat,Y : CGFloat ,psW : CGFloat ,H : CGFloat) {
        self.origin = CGPoint(x: psX / 375 * getWIDTH(), y: Y)
        self.size = CGSize(width: psW / 375 * getWIDTH(), height: H)
    }
    /// iPhone 宽度按屏幕比例 高度同宽度比（宽高比固定）
    init(psX : CGFloat,pswY : CGFloat ,psW : CGFloat ,pswH : CGFloat) {
        self.origin = CGPoint(x: psX / 375 * getWIDTH(), y: pswY / 375 * getWIDTH())
        self.size = CGSize(width: psW / 375 * getWIDTH(), height: pswH / 375 * getWIDTH())
    }
}

extension UILabel{
    func setProperty(color: UIColor, fontName : String ,fontSize : CGFloat) {
        self.textColor = color
        self.font = UIFont(name: fontName, size: fontSize)
    }
    func setProperty(color: UIColor, fontName : String ,fontScaleSize : CGFloat) {
        self.textColor = color
        self.font = UIFont(name: fontName, size: fontScaleSize / 768 * getHeith())
    }
    func setVText(vText : String) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let heigh = self.font.pointSize
        var index : Int = 0
        for s  in vText {
            let label = UILabel()
            label.font = self.font
            label.textColor = self.textColor
            label.backgroundColor = UIColor.clear
            label.text = "\(s)"
            label.sizeToFit()
            label.frame = CGRect(x: (self.frame.width - label.frame.width)/2 , y: heigh/2 + CGFloat(index) * heigh, width: label.frame.width, height: label.frame.height)
            if label.frame.maxY > self.frame.height - heigh || "\(s)" == "(" || "\(s)" == "（" {
                return
            }
            DispatchQueue.main.async {
                self.addSubview(label)
            }
            index += 1
        }
    }
    func removeVText(){
        for label in self.subviews {
            label.removeFromSuperview()
        }
    }
    
    func getTextRectSize() -> CGRect {
        let attributes : [NSAttributedStringKey:Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): self.font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = CGSize(width: CGFloat(MAXFLOAT), height: self.font.pointSize)
        let rect : CGRect = self.text!.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect;
    }
    override open func mutableCopy() -> Any {
        let lebel = UILabel(frame: self.frame)
        lebel.backgroundColor = self.backgroundColor
        lebel.textColor = self.textColor
        lebel.font = self.font
        lebel.text = self.text
        return lebel
    }
    func showTextWithAnimiation() {
        
    }
}
extension UITextView {
    func setProperty(color: UIColor, fontName : String ,fontSize : CGFloat) {
        self.textColor = color
        self.font = UIFont(name: fontName, size: fontSize)
    }
}
extension UIButton{
    func setProperty(color: UIColor, fontName : String ,fontSize : CGFloat) {
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = UIFont(name: fontName, size: fontSize)
    }
    func setProperty(color: UIColor, fontName : String ,fontScaleSize : CGFloat) {
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = UIFont(name: fontName, size: fontScaleSize / 768 * getHeith())
    }
    
    func verticalImageAndTitle(spacing : CGFloat){
        let imageSize = self.imageView?.frame.size
        var titleSize = self.titleLabel?.frame.size
        let textSize = self.titleLabel?.getTextRectSize()
        let frameSize = textSize
        if (titleSize?.width)! + 0.5 < (frameSize?.width)! {
            titleSize?.width = (frameSize?.width)!
        }
        let totalHeight = (imageSize?.height)! + (titleSize?.height)! + spacing
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - (imageSize?.height)!), left: 0, bottom: 0, right: -(titleSize?.width)!)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize?.width)!, bottom: -(totalHeight - (titleSize?.height)!), right: 0)
    }
    func 图片居右() {
        if let imageView = self.imageView ,let label = self.titleLabel {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: label.frame.size.width, bottom: 0, right: -label.frame.size.width)
        }
    }
    func setImageWithUrl(imageUrl : String)  {
        
        if let 资源根路径 = 资源根路径 {
            safeMainThread {
                self.setBackgroundImage(UIImage(named: "曲谱加载中"), for: .normal)
            }
            if let uurl = URL(string:资源根路径 + imageUrl) {
                var request = URLRequest(url: uurl)
                request.cachePolicy = .reloadIgnoringCacheData
                let cachedURLResponse = URLCache.shared.cachedResponse(for: request)
                if cachedURLResponse != nil  {
                    if let userInfo = cachedURLResponse?.userInfo {
                        if let date = userInfo["date"] as? Date{
                            if Date().timeIntervalSince(date) < 24 * 60 * 60 {
                                safeMainThread {
                                    let image = UIImage(data: (cachedURLResponse?.data)!)
                                    if  let image = image {
                                        self.setBackgroundImage(image, for: .normal)
                                    }
                                }
                                return
                            }
                        }
                    }
                }
                let dataTask = URLSession.shared.dataTask(with: request,
                                                          completionHandler: { (data, resp, err) in
                                                            if data != nil {
                                                                safeMainThread {
                                                                    self.setBackgroundImage(UIImage(data: (data)!), for: .normal)
                                                                }
                                                                let cachedURLResponse  = CachedURLResponse(response: resp!, data: data!, userInfo: ["date":
                                                                    Date()], storagePolicy: .allowed)
                                                                URLCache.shared.storeCachedResponse(cachedURLResponse, for: request)
                                                            }else{
                                                                safeMainThread {
                                                                    self.setBackgroundImage(UIImage(named: "曲谱加载失败"), for: .normal)

                                                                }
                                                            }
                } )
                dataTask.resume()
            }else{
                self.setBackgroundImage(UIImage(named: "曲谱加载失败"), for: .normal)
            }
        }
    }
}
extension UIViewController {
    //// BookDetailview 中还有其它的添加背景方法
    func 添加背景图(){
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: getWIDTH(), height: getHeith()))
        imageView.image = UIImage(named: "WechatIMG648")
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints {(make) -> Void in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    func 上面的安全位置() -> ConstraintItem {
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.top
        }else{
            return self.topLayoutGuide.snp.bottom
        }
    }
    
    func 下面的安全位置() -> ConstraintItem {
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.bottom
        }else{
            return self.bottomLayoutGuide.snp.top
        }
    }
}

extension UIView {
    var scaleFrame : CGRect {
        get{
            return CGRect(x: scalefor(x: self.frame.midX), y: scalefor(y: self.frame.origin.y), width: scalefor(x: self.frame.width), height: scalefor(y: self.frame.height))
        }
    }
}
func safeMainThread(action:@escaping ()->Void){
    if Thread.isMainThread {
        action()
    }else{
        DispatchQueue.main.async {
            action()
        }
    }
}


extension String {
    var  securityToInt : Int {
       return Int(self) ?? -1
    }
    var  securityToCGFloat : CGFloat {
        return CGFloat(self.securityToInt)
    }
}
extension CGPoint {
    init(dic: [String:String]) {
        let xstr = dic["x"] ?? "-1"
        let ystr = dic["y"] ?? "-1"
        x = getScale(x: CGFloat(Int(xstr) ?? -1))
        y = getScale(y: CGFloat(Int(ystr) ?? -1))
    }
}
