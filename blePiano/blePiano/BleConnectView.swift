//
//  BleConnectView.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/6/5.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import CoreBluetooth

var scroViewX: CGFloat = 130

protocol BleControldelegate : NSObjectProtocol {
    func 展示搜索到的蓝牙(peripheral: [CBPeripheral])
}

class BleConnectViewTableViewCellModel: NSObject {
    var stati: Int! // 0 未连接 1 连接中 2 以连接  -1 无
    var bleName: String?
    var backValue: CBPeripheral?
    init(peripheral:CBPeripheral) {
        super.init()
        if peripheral.state == .connected {
            self.stati = 2
        }else if peripheral.state == .connecting {
            self.stati = 1
        }else{
            self.stati = 0
        }
        bleName = peripheral.name
        backValue = peripheral
    }
    override init() {
        super.init()
        self.stati = -1
    }
    static func  creatBleConnectViewTableViewCellModel(peripheral: [CBPeripheral]) ->[[BleConnectViewTableViewCellModel]]
    {
        var fistArr: [BleConnectViewTableViewCellModel] = [BleConnectViewTableViewCellModel()]
        var lastArr: [BleConnectViewTableViewCellModel] = []
        for per in peripheral {
            let mod = BleConnectViewTableViewCellModel(peripheral: per)
            if per.state == .connected {
                fistArr.removeAll()
                fistArr.append(mod)
            }else{
                lastArr.append(mod)
            }
        }
        return [fistArr,lastArr]
    }
}

class BleConnectViewTableViewCell: HFTableViewCell {
    var bleNamelabel: UILabel!
    var bleNamelabel1: UILabel?
    
    var staticLabel: UILabel!
    var cellH = getScale(y: 60)
    var activeView: UIActivityIndicatorView!
    
    var timer: Timer!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BleConnectViewTableViewCell.动画), userInfo: nil, repeats: true)
        if 是iPhone {
            cellH = psy(y: 32)
            bleNamelabel = UILabel(frame: CGRect(x: 0, y: 0, width: psyx(x: 330)/2 - scroViewX, height: cellH))
            bleNamelabel.setProperty(color: Fix颜色6_0, fontName: "SFNSDisplay-Regular", fontSize: psy(y: 12))
            bleNamelabel.textAlignment = .left
            staticLabel = UILabel(frame: CGRect(x: bleNamelabel.frame.maxX, y: 0, width: psyx(x: 330)/2 - scroViewX - cellH, height: cellH))
            staticLabel.setProperty(color: Fix颜色6_0, fontName: "SFNSDisplay-Regular", fontSize: psy(y: 12))
            staticLabel.textAlignment = .right
            activeView = UIActivityIndicatorView(frame: CGRect(x: staticLabel.frame.maxX, y: 0, width: cellH, height: cellH))
        }else{
            bleNamelabel = UILabel(frame: CGRect(scaleX: 0, Y: 0, scaleW: (弹窗宽度 - scroViewX * 2)/2, H: cellH))
            bleNamelabel.setProperty(color: Fix颜色6_0, fontName: "SFNSDisplay-Regular", fontScaleSize: getScale(y: 16))
            bleNamelabel.textAlignment = .left
            staticLabel = UILabel(frame: CGRect(scaleX: scalefor(x: bleNamelabel.frame.maxX), scaleY: 0, scaleW:  (弹窗宽度 - scroViewX * 2)/2 - 60 , scaleH: cellH))
            staticLabel.setProperty(color: Fix颜色6_0, fontName: "SFNSDisplay-Regular", fontScaleSize: getScale(y: 16))
            staticLabel.textAlignment = .right
            activeView = UIActivityIndicatorView(frame: CGRect(scaleX: scalefor(x: staticLabel.frame.maxX), scaleY: 0, scaleW: 60, scaleH: 60))
        }
        
        self.bleNamelabel.clipsToBounds = true
        activeView.hidesWhenStopped = true
        self.addSubview(activeView)
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bleNamelabel)
        self.addSubview(staticLabel)
    }
    override func addData(anyObject: AnyObject) -> CGFloat {
        safeMainThread {
            let model = anyObject as! BleConnectViewTableViewCellModel
            if model.stati == -1{
                self.bleNamelabel.text = nil
            }else{
                self.bleNamelabel.text = model.backValue?.name ?? "未知名"
            }
            self.bleNamelabel1?.removeFromSuperview()
            self.bleNamelabel1 = self.bleNamelabel.mutableCopy() as? UILabel
            self.bleNamelabel1?.sizeToFit()
            if (self.bleNamelabel1?.frame.width)! > self.bleNamelabel.frame.width {
                self.开始动画()
            }else{
                self.停止动画()
            }
            if model.stati == 0 {
                self.staticLabel.text = "未连接"
                self.activeView.stopAnimating()
            }else if model.stati == 1 {
                self.staticLabel.text = "连接中"
                self.activeView.startAnimating()
            }else if model.stati == 2 {
                self.activeView.stopAnimating()
                self.staticLabel.text = "已连接"
            }else{
                self.activeView.stopAnimating()
                self.staticLabel.text = ""
            }
        }
        return cellH
    }

    func 开始动画() {
       
        self.bleNamelabel.text = nil
        self.bleNamelabel1?.frame = CGRect(x: 0, y: (self.bleNamelabel.frame.height - (self.bleNamelabel1?.frame.height)!)/2, width: (self.bleNamelabel1?.frame.width)!, height: (self.bleNamelabel1?.frame.height)!)
        self.bleNamelabel.addSubview(self.bleNamelabel1!)
        timer.fire()
        
    }
    func 停止动画() {
        self.bleNamelabel.text = self.bleNamelabel1?.text
        self.bleNamelabel1?.removeFromSuperview()
        timer.invalidate()
    }
    @objc func 动画(){
        guard self.bleNamelabel1 != nil else {
            return
        }
        self.bleNamelabel.text = nil
        if (self.bleNamelabel1?.frame.minX)! < 0 {
            UIView.animate(withDuration: 1, animations: {
                self.bleNamelabel1?.frame = CGRect(x: 0, y: (self.bleNamelabel1?.frame.minY)!, width: (self.bleNamelabel1?.frame.width)!, height: (self.bleNamelabel1?.frame.height)!)
            }, completion: {
               (finsh) in
            })
        }else{
            UIView.animate(withDuration: 1, animations: {
                self.bleNamelabel1?.frame = CGRect(x: self.bleNamelabel.frame.width - (self.bleNamelabel1?.frame.width)!, y: (self.bleNamelabel1?.frame.minY)!, width: (self.bleNamelabel1?.frame.width)!, height: (self.bleNamelabel1?.frame.height)!)
            }, completion: {
               (finsh) in
                
            })
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        timer.invalidate()
        timer = nil
    }
}

class BleConnectViewTableView: HFTableView,HFTableViewDelegate {
    override init(frame: CGRect, style: UITableViewStyle, tipAction: @escaping ((_ indexPath: IndexPath, _ btnIndex: Int, _ object: AnyObject?) -> Void)) {
        super.init(frame: frame, style: style, tipAction: tipAction)
        self.bounces = false
        self.hfDelegate = self
        self.separatorStyle = .none
    }
    func hftableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        if section == 1 {
            let lable = UILabel()
            lable.text = "选择连接蓝牙设备……"
            if 是iPhone {
                lable.setProperty(color: Fix颜色6_0, fontName: "PingFangSC-Regular", fontSize: psyx(x: 10))
            }else{
                lable.setProperty(color: Fix颜色6_0, fontName: "PingFangSC-Regular", fontScaleSize: 12)
            }
            return lable
        }else{
            return nil
        }
    }
    func hftableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        return nil
    }
    func hftableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        if section == 1 {
            if 是iPhone {
                return psy(y: 52)
            }
            return getScale(y: 60)
        }else{
            return 0.0001
        }
    }
    func hftableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func relodata( model: [[BleConnectViewTableViewCellModel ]]) {
        var forMatArr: [[String]] = []
        for arr in model {
            var strArr: [String] = []
            for _ in arr {
                strArr.append("BleConnectViewTableViewCell")
            }
            forMatArr.append(strArr)
        }
        self.reloadData(dataSourceArr: model, dataFormatArr: forMatArr)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BleConnectView: UIView,BleControldelegate {
    var borderView: UIView!
    var titleLabel: UILabel!
    var scroView: BleConnectViewTableView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        var scroViewFrame: CGRect!
        if 是iPhone {
            let width = psyx(x: 330)
            borderView = UIView(frame: CGRect(x: (getWIDTH() - width)/2, y: pMainNavigationVbarHeigh + psy(y: 6), width: width, height: psyx(x: 236)))
            borderView.layer.cornerRadius = psx( 10)
            titleLabel = UILabel(frame: CGRect(x: 0, y: psy(y: 20), width: width, height: psy(y: 18)))
            titleLabel.setProperty(color: Fix颜色6_0, fontName: "PingFangSC-Regular", fontSize: psy(y: 18))
            scroViewX = psyx(x: 40)
            scroViewFrame = CGRect(x: scroViewX, y: psy(y: 58), width: (frame.width - scroViewX)/2, height: frame.height - psy(y: 133))
        }else{
            borderView = UIView(frame: CGRect(scaleX: (1024 - 弹窗宽度) / 2, scaleY: (768 - 弹窗高度)/2, scaleW: 弹窗宽度, scaleH: 弹窗高度))
            borderView.layer.cornerRadius = getScale(x: 10)
            titleLabel = UILabel(frame: CGRect(scaleX: 0, scaleY: 50, scaleW: 弹窗宽度, scaleH: 24))
            titleLabel.setProperty(color: Fix颜色6_0, fontName: "PingFangSC-Regular", fontScaleSize: 24)
            scroViewFrame = CGRect(scaleX: scroViewX, scaleY: 120, scaleW: 弹窗宽度 - scroViewX * 2, scaleH: 弹窗高度 - 120 - 50)
        }
        borderView.backgroundColor = Fix黑色7
        self.addSubview(borderView)
        
        
        titleLabel.textAlignment = .center
        titleLabel.text = "当前搜索到的设备"
        self.borderView.addSubview(titleLabel)
        scroView = BleConnectViewTableView(frame: scroViewFrame, style: .plain, tipAction: { (indexpatch, index, anyObjecgt) in
            let mode = anyObjecgt as! BleConnectViewTableViewCellModel
            if mode.stati == 1 || mode.stati == -1 {
                
            }else if mode.stati == 0 {
                MIDIDeviceControl.shard.连接设备(peripheral: mode.backValue!)
            }else if mode.stati == 2 {
                MIDIDeviceControl.shard.断开设备()
            }
        })
        scroView.register(BleConnectViewTableViewCell.self, forCellReuseIdentifier: "BleConnectViewTableViewCell")
        scroView.backgroundColor = UIColor.clear
        borderView.addSubview(scroView)
    }
    
    func 展示搜索到的蓝牙(peripheral: [CBPeripheral]) {
        let dataArr: [[BleConnectViewTableViewCellModel]] = BleConnectViewTableViewCellModel.creatBleConnectViewTableViewCellModel(peripheral: peripheral)
        scroView.relodata(model: dataArr)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func 创建蓝牙连接视图() -> BleConnectView {
        let  bleConnectView = BleConnectView(frame: CGRect(scaleX: 0, scaleY: 0, scaleW: 1024, scaleH: 768))
    
        return bleConnectView
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch?.location(in: self)
        if !borderView.frame.contains(point!) {
            MIDIDeviceControl.shard.停止查找蓝牙()
            self.removeFromSuperview()
        }
    }

}
