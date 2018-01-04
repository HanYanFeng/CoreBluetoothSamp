//
//  HFDefine.swift
//  琴加
//
//  Created by 袁银花 on 2017/5/16.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

typealias 网络访问回调类型 = ( _ succed : Bool,_ reasion :String?, _ backObject : AnyObject?) -> Void
let serialQueue = DispatchQueue(label: "Mazy", attributes: .init(rawValue: 0))

///开发模式
let rootUrl =  "http://121.41.128.49:9017"

var 资源根路径 : String?
///生产模式
//let rootUrl = "http://121.41.128.49:8381"


///3.1.1	获取所有曲谱信息
let getAll = "/qin_plus/main/getAll"
///3.1.2	获取指定曲谱信息
let getMusicItem = "/qin_plus/main/getMusicItem"

///3.1.3	获取所有图书信息
 let getBookAll = "/qin_plus/main/getBookAll"
///3.1.4	获取指定图书曲谱信息
let getMusicOfBook = "/qin_plus/main/getMusicOfBook"
///3.2.1	用户注册 
let userRegister = "/qin_plus/pc/userRegister"

///3.2.2	用户登录退出
let userLogInfo = "/qin_plus/pc/userLogInfo"

///3.2.3	更新用户信息
let updateUserInfo = "/qin_plus/pc/updateUserInfo"


let WIDTH = UIScreen.main.bounds.width
let HEIGH = UIScreen.main.bounds.height
func getHeith() -> CGFloat {
//
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
        return WIDTH > HEIGH ? WIDTH : HEIGH
    }else{
        return WIDTH > HEIGH ? HEIGH : WIDTH
    }
}
func getWIDTH() -> CGFloat {
//
    if OCFunction.currentViewController().preferredInterfaceOrientationForPresentation == .portrait {
        return WIDTH > HEIGH ? HEIGH : WIDTH
    }else{
        return WIDTH > HEIGH ? WIDTH : HEIGH
    }
}
//let bottomItemInfo = [("经典教程","经典选中","经典"),("流行音乐","流行选中","流行"),("考级专区","考级选中","考级"),("搜索","搜索选中","搜索"),("个人中心","我的选中","我的")]
//let bottomItemInfoiPad = [("经典教程","经典选中","经典"),("流行音乐","流行选中","流行"),("考级专区","考级选中","考级"),("音乐教室","课堂选中","课堂"),("搜索","搜索选中","搜索"),("个人中心","我的选中","我的")]
let bottomItemInfo = [("曲谱分类","曲谱选中","曲谱模式"),("搜索","搜索选中","搜索"),("个人中心","我的选中","我的")]
let bottomItemInfoiPad = [("曲谱分类","曲谱选中","曲谱模式"),("视频教学","视频选中","视频"),("音乐教室","课堂选中","课堂"),("搜索","搜索选中","搜索"),("个人中心","我的选中","我的")]
/// iPad 尺寸
let MainBottomSeletViewHeigh : CGFloat = 56
let MainNavigationVbarHeigh : CGFloat = 71
let MainLageClassDetileViewHeigh : CGFloat = 768 - MainBottomSeletViewHeigh - MainNavigationVbarHeigh
let SmoreClassnaviViewHeigh : CGFloat = 60
let MainShowBookViewHeigh = MainLageClassDetileViewHeigh - SmoreClassnaviViewHeigh
let SaveCollectViewW = (135.0 + 40.0 + 65) * 4//1024 - 64 * 2 + 65
///曲谱播放上面一排的高
let ScorePlayVCControViewH : CGFloat = 72

let 弹窗宽度 : CGFloat = 700.0
let 弹窗高度 : CGFloat = 500.0
let 键盘高度 : CGFloat = 107.5
/// iPhone 尺寸
let pMainNavigationVbarHeigh : CGFloat = 64
let pMainBottomSeletViewHeigh : CGFloat = 49
let pSmoreClassnaviViewHeigh : CGFloat = 40
var pMainShowBookViewHeigh : CGFloat!
let pScorePlayVCControViewH : CGFloat = 64 + 2
var p键盘高度 : CGFloat {
    return  72.0 / 375 * (WIDTH > HEIGH ? HEIGH : WIDTH)
}

