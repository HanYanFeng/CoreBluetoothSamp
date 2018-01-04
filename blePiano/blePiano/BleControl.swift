//
//  BleControl.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/6/5.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import CoreBluetooth

class BleTask: NSObject {
    let type : Int
    init(_ typee : Int) {
       type = typee
    }
}
class BleTaskIConnectIdentifer: BleTask {
    private var identify : String
    private var backAction: (_ succed: Bool,_ reason:String?)->Void
    init(_ identif : String,back:@escaping (_ succed: Bool,_ reason:String?) -> Void) {
        identify = identif
        backAction = back
        super.init(1)
        let arr = identify.components(separatedBy: "-")
        if arr.count == 5
            && arr[0].count == 8
            && arr[1].count == 4
            && arr[2].count == 4
            && arr[3].count == 4
            && (arr[4].count == 12 || arr[4].count == 16) {
        }else{
            DispatchQueue.main.async {
                back(false, "二维码格式错误")
            }
            return
        }
    }
    /// 开始任务
    func taskResam(){
        if let _ =  BleControl.单例.开始查找蓝牙设备() {
            DispatchQueue.main.async {
                self.backAction(false, "蓝牙未开启")
            }
        }else{
            BleControl.单例.添加任务(task: self)
//            let bleTaskIConnectIdentifer = self
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: {
//                [weak bleTaskIConnectIdentifer] in
//                if let _ =  bleTaskIConnectIdentifer {
//                    showErrorWithAlert2(string: "请检查钢琴开关是否打开", fineshBack: nil)
//                }
//            })
        }
    }
    fileprivate func 搜索到设备(peripheral : CBPeripheral) {
        if peripheral.identifier.uuidString == self.identify {
           _ = BleControl.单例.连接设备(peripheral: peripheral)
        }
    }
    fileprivate func 连接成功(peripheral : CBPeripheral) {
        if peripheral.identifier.uuidString == self.identify {
            self.backAction(true, nil)
            BleControl.单例.移除任务(task: self)
            BleControl.单例.停止搜索()
        }
    }
}


let serviceid = CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")
let characteristicid1 = CBUUID(string: "7772E5DB-3868-4112-A1A9-F2669D106BF3")
let bleconnectchange = "BleControlbleconnectchange"
class BleControl: NSObject,CBCentralManagerDelegate ,CBPeripheralDelegate {
    var centerManager : CBCentralManager!
    var connectPeripheral : CBPeripheral?
    var lastPeripheral : CBPeripheral?
    var peripherals : [CBPeripheral]?
    weak var delegate : BleControldelegate?
    
    static var 单例 : BleControl = BleControl()
    private var 任务队列 : [BleTask] = []
    override init() {
        super.init()
        centerManager  = CBCentralManager(delegate: self, queue: nil)
        peripherals = []
    }
    var connect : Bool {
        get {
            if let connectPeripheral = connectPeripheral {
                if connectPeripheral.state == .connected {
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        }
        set(newValue){
            NotificationCenter.default.post(name: Notification.Name(rawValue:bleconnectchange), object: false)
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if centerManager.state != .poweredOn {
        }
    }
    func 用Identifier连接(identifier:String) {
        
        
    }
    
    func 开始查找蓝牙设备() -> String?{
        if centerManager.state != .poweredOn {
            return "蓝牙不可用，请打开蓝牙"
        }else{
            peripherals = []
            if self.connectPeripheral != nil {
                peripherals?.append(self.connectPeripheral!)
            }
            centerManager.scanForPeripherals(withServices: [serviceid], options: nil)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
            return nil
        }
    }
    func 移除任务(task : BleTask) {
       self.任务队列 = self.任务队列.filter() {
            return $0 != task
        }
    }
    func 添加任务(task : BleTask)  {
        self.任务队列.append(task)
    }
    func 停止搜索()
    {
        centerManager.stopScan()
    }
    func 连接设备(peripheral : CBPeripheral)  -> String?
    {
        if centerManager.state != .poweredOn {
            return "蓝牙不可用，请打开蓝牙"
        }else{
            if self.connectPeripheral != nil && self.connectPeripheral?.state == .connected {
                lastPeripheral = peripheral
                self.centerManager.cancelPeripheralConnection(self.connectPeripheral!)
            }else{
                
            }
            centerManager.connect(peripheral, options: nil)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
            return nil
        }
    }
    func 断开设备(peripheral : CBPeripheral)
    {
        if peripheral ==  self.connectPeripheral {
            self.centerManager.cancelPeripheralConnection(self.connectPeripheral!)
        }
    }
    func 断开设备(){
        if let peripheral =  self.connectPeripheral {
            self.centerManager.cancelPeripheralConnection(peripheral)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !(self.peripherals?.contains(peripheral))! {
            self.peripherals?.append(peripheral)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
        }
        print(peripheral.identifier.uuidString)
        for item in self.任务队列 {
            switch item.type {
            case 1 :
               let itemm = item as! BleTaskIConnectIdentifer
                itemm.搜索到设备(peripheral: peripheral)
            default :
                continue
            }
        }
    }
    ///
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceid])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙断了")
        if peripheral.identifier.uuidString == self.connectPeripheral?.identifier.uuidString {
            self.connectPeripheral = nil
            self.connect = false
            if self.delegate != nil {
                self.delegate?.展示搜索到的蓝牙(peripheral: self.peripherals!)
            }
        }
    }
    ///
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil {
            peripheral.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
        }else{
            print("出错了1")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil {
            for characteristic in service.characteristics! {
                if characteristic.uuid == characteristicid1{
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }else{
            print("出错了2")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            self.connectPeripheral = peripheral
            self.connect = true
            self.delegate?.展示搜索到的蓝牙(peripheral: self.peripherals!)
            for item in self.任务队列 {
                switch item.type {
                case 1 :
                    let itemm = item as! BleTaskIConnectIdentifer
                    itemm.连接成功(peripheral: peripheral)
                default :
                    continue
                }
            }
        }else{
            print("出错了3")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            MIDIDeviceControl.shard.收到蓝牙数据(data: data)
//            for index in data {
//                print(index)
//            }
//            print("-----------")
        }
    }
  
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if error != nil{
//            print("出现发送错误");
//        }else{
//            
//        }
//        var sss = "完成任务"
//        for indd in (任务队列.first)! {
//            sss += "\(indd)"
//        }
//        print(sss)
//        任务队列.remove(at: 0)
//        if 任务队列.count != 0 {
//            self.senData(data: 任务队列.first!)
//            
//        }
    }
   
//    var 基准时间 : Date?
//    var 序列 : Int?
//    var label = UITextView(frame: CGRect(x: 0, y: 0, width: 1024, height: 100))
    func sendData(data: Data) {
//        if 基准时间 == nil {
//            基准时间 = Date()
//            序列 = 0
//            label.text = ""
//        }
////        let 差 = Date().timeIntervalSince(基准时间!)
////        print("第\(序列)次发 时间：\(差)")
//        var 差 = String()
//        for intt in data {
//            差 = 差 + " \(intt)"
//        }
//        DispatchQueue.main.async {
//            self.label.text = self.label.text! + "||\(差)"
//            self.label.textColor = UIColor.red
//            self.label.backgroundColor = UIColor.white
//            (ScorePlayer.shard.controView as! UIView).addSubview(self.label)
//        }
//        
//        序列! += 1
        
//        var sendDate = Data()
//        for dat in data {
//            if sendDate.count == 5 {
//                var str = "添加任务"
//                for indd in sendDate {
//                    str += "\(indd)"
//                }
//                print(str)
//                任务队列.append(sendDate)
//                if 任务队列.count == 1 {
//                    self.senData(data: 任务队列.first!)
//                }
//                sendDate = Data()
//            }else{
//                sendDate.append(dat)
//            }
//        }
        self.senData(data: data)

//        var str = "添加任务"
//        for indd in data {
//            str += "\(indd)"
//        }
//        print(str)
//        任务队列.append(data)
//        if 任务队列.count == 1 {
//            self.senData(data: 任务队列.first!)
//        }
    }
    func senData(data: Data){

        
        if let services = self.connectPeripheral?.services {
            for serve in services {
                if serve.uuid == serviceid {
                    if let characteristics = serve.characteristics {
                        for characteristic in characteristics {
                            if characteristic.uuid ==  characteristicid1{
                                DispatchQueue.global().async {
                                    self.connectPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
                                }
//                                self.connectPeripheral?.writeValue(data, for: (self.connectPeripheral?.services?.first?.characteristics?.first)!, type: .withoutResponse)
                            }
                        }
                    }
                }
            }
        }
        
    }
}


class BlePeripheral: NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    
    var central: CBCentral?
    
    var service: CBMutableService?
    
    var characteristic: CBCharacteristic?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main)
        service = CBMutableService(type: serviceid, primary: true)
        
        characteristic = CBMutableCharacteristic(type: characteristicid1, properties:  CBCharacteristicProperties(rawValue: 26), value: Data(), permissions: CBAttributePermissions(rawValue: 3))
    }
    
    /// MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        if peripheral.state == .poweredOn {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.peripheralManager.add(self.service!)
                self.service?.characteristics = [self.characteristic!]
                self.peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "PeripheralManager",CBAdvertisementDataServiceUUIDsKey: [serviceid]])
            })
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print(error)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
        for request in requests.enumerated() {
            if request.element.characteristic.uuid == characteristicid1 {
                if request.element.offset != 0 {
                    self.peripheralManager.respond(to: request.element, withResult: .requestNotSupported)
                }else{
//                    self.characteristic?.value = request.element.value
                }
            }else{
                self.peripheralManager.respond(to: request.element, withResult: .requestNotSupported)
            }
        }
        MIDIDeviceControl.shard.收到蓝牙数据(data: (characteristic?.value!)!)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print(characteristic)
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]){
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?){
        
    }
    

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest){
        if request.characteristic.uuid == characteristicid1 {
            if request.offset <= (characteristic?.value?.count)! {
                request.value = characteristic?.value?.subdata(in: (request.offset)..<((characteristic?.value?.count)! - request.offset))
                self.peripheralManager.respond(to: request, withResult: .success)
            }else{
                self.peripheralManager.respond(to: request, withResult: .invalidOffset)
            }
        }else{
            self.peripheralManager.respond(to: request, withResult: .requestNotSupported)
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager){
    
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?){
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?){
    
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?){
    
    }
}
