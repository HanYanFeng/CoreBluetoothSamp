//
//  ViewController.swift
//  blePiano
//
//  Created by 韩艳锋 on 2018/1/3.
//  Copyright © 2018年 韩艳锋. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, MIDIDataReceiveDelegate {

    let textView = UITextView()
    var bleConnectView : BleConnectView!

    var blePeripheral: BlePeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(textView)
        textView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(蓝牙按钮点击事件))
        
        self.bleConnectView = BleConnectView.创建蓝牙连接视图()
        
        MIDIDeviceControl.shard.delegate = self
        blePeripheral = BlePeripheral()

    }
    
    @objc func 蓝牙按钮点击事件() {
        self.view.addSubview(self.bleConnectView)
        self.bleConnectView.展示搜索到的蓝牙(peripheral: [])
        MIDIDeviceControl.shard.开始搜索蓝牙(delegate: self.bleConnectView)
    }
    
    func 收到MIDI数据(array : [UInt8])
    {
        var appText = ""
        for item in array {
            appText += " \(item)"
        }
        
        var newText = self.textView.text
        if newText == nil {
            newText = ""
        }
        newText = newText! + "\n" + appText
        
        self.textView.text = newText
        self.textView.scrollRangeToVisible(NSRange(location: (newText?.count)! - 1, length: 0))
    }
}

