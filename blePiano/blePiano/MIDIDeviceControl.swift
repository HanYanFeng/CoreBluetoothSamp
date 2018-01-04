//
//  MIDIDeviceControl.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/12/20.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol MIDIDataReceiveDelegate : NSObjectProtocol {
    func 收到MIDI数据(array : [UInt8])
}

class MIDIDeviceControl: NSObject {
    
    static var shard = MIDIDeviceControl()
    
    var delegate: MIDIDataReceiveDelegate?
    
    private var _client: MIDIClientRef = 0
    private var _inputPort: MIDIPortRef = 0
    private var _outputPort: MIDIPortRef = 0
    private var _entity: MIDIEntityRef = 0
    private var _ocMidiDeviceContro : OCMIDIControl!
    private var _bleControl: BleControl = BleControl.单例
    
    private var 提示 = true
    override init() {
       
        super.init()
        _ocMidiDeviceContro = OCMIDIControl(back: { (data) in
            self.收到USB数据(data: data!)
        })
        
        _ocMidiDeviceContro.connectChange = {
            self.usb连接变化了()
        }
        _ocMidiDeviceContro.message = { (message) in
        }
    }
    
    func 开始搜索蓝牙(delegate: BleControldelegate) {
        self._bleControl.delegate = delegate
        _ = self._bleControl.开始查找蓝牙设备()
    }
    
    func 停止查找蓝牙() {
        self._bleControl.停止搜索()
    }
    
    func 连接设备(peripheral: CBPeripheral) {
       _ = self._bleControl.连接设备(peripheral: peripheral)
    }
    
    func 断开设备() {
        self._bleControl.断开设备()
    }
}


private extension MIDIDeviceControl{
    
    func 收到USB数据(data: Data) {
//        MidiTransfer.usbTransToMidiComment(data: data) { (array) in
//            if let delegate = MIDIDeviceControl.shard.delegate {
//                delegate.收到MIDI数据(array:array)
//            }
//        }
    }
    
    func usb连接变化了() {
//        NotificationCenter.default.post(name: NSNotification.Name.init(usbConnectChange), object: nil)
        if self.是USB连接 {
            self._bleControl.断开设备()
        }
    }
}

extension MIDIDeviceControl {

    var 是否连接: Bool {
        return _ocMidiDeviceContro.isConnect || _bleControl.connect
    }
    
    var 是USB连接: Bool {
        return _ocMidiDeviceContro.isConnect
    }
    
    func app进入前台() {
        _ocMidiDeviceContro.refreshConnectStatus()
    }

    var 是蓝牙连接: Bool {
        return _bleControl.connect//_ocMidiDeviceContro.isConnect && !_ocMidiDeviceContro.isUsb
    }
    
    func 发送数据(data: Data)
    {
        if self.是USB连接 {
            self._ocMidiDeviceContro.sendMIdiData(data)
        }else if self._bleControl.connect {
            guard data.count >= 2 else {
                return
            }
            if data[0] & 0x80 == 0x80 && data[1] & 0x80 == 0x80 {
                self._bleControl.senData(data: data)
            }else{
                var da = Data(bytes: [0x80,0x80])
                da.append(data)
                self._bleControl.senData(data: da)
            }
        }
    }
    
    func 收到蓝牙数据(data: Data) {
        
        var array: [UInt8] = []
        
        for item in data {
            array.append(item)
        }
        
        if let delegate = MIDIDeviceControl.shard.delegate {
            delegate.收到MIDI数据(array:array)
        }
    }
}

//        class Clas1 {
//
//        }
//        let nn = Clas1()
//        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 255, alignedTo: 1)
//        bytesPointer.storeBytes(of: nn, as: Clas1.self)
//
//        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 255, alignedTo: 1)
//        bytesPointer.storeBytes(of: self, as: MIDIDeviceControl.self)
//
//        let func1: CoreMIDI.MIDINotifyProc = { (message, ttt) in
//            MIDIDeviceControl.shard.didChangeStatus(notification: message)
//        }
//
//        let func2: CoreMIDI.MIDIReadProc = { ( midiPackListPointer, unSafePointer, unSafeRawPointer) in
//            MIDIDeviceControl.shard.receiveMessage(message: midiPackListPointer)
//        }
//
//        var status = MIDIClientCreate("client" as CFString, func1, bytesPointer, UnsafeMutablePointer<MIDIClientRef>(&_client))
//        if status != 0 {
//            print("初始化失败")
//        }
//
//        status = MIDIInputPortCreate(_client, "_inputPort" as CFString, func2, bytesPointer, UnsafeMutablePointer<MIDIClientRef>(&_inputPort))
//        if status != 0 {
//            print("初始化失败")
//        }
//
//        status = MIDIOutputPortCreate(_client, "_outputPort" as CFString, &_inputPort)
//        if status != 0 {
//            print("初始化失败")
//        }
//        const Byte * byte = data.bytes;
//        NSData * dataNew = nil;
//        if ( ( (*byte & 0x80) == 0x80 )&&( (*(byte + 1) & 0x80) == 0x80 ) ) {
//            dataNew = [NSData dataWithBytes:byte + 2 length:data.length - 2];
//            byte = dataNew.bytes;
//        }else{
//            dataNew = data;
//        }
//        //    dataNew = data;
//        NSLog(@"%@",dataNew);
//        char buffer[256];
//        MIDIPacketList *packets = (MIDIPacketList *)buffer;
//        MIDIPacket *packet = MIDIPacketListInit(packets);
//
//
//        packet = MIDIPacketListAdd(packets, 256, packet, 0, dataNew.length, byte);
//
//        MIDIEndpointRef destination = MIDIEntityGetDestination(_entity, 0);
//        OSStatus dd = MIDISend(_outputPort, destination, packets);
//        if (dd == 0) {
//            NSLog(@"usb发送数据成功");
//        }
//        var dataNew: Data!
//        if data[0] & 0x80 == 0x80 && data[1] & 0x80 == 0x80 {
//            dataNew = data.dropFirst()
//            dataNew = dataNew.dropFirst()
//        }else{
//            dataNew = data
//        }
//        var packetlist = MIDIPacketList()
//        let packetList =  UnsafeMutablePointer<MIDIPacketList>(&packetlist)
//        var packet = MIDIPacketListInit(packetList)
//        packet = MIDIPacketListAdd(packetList, 256, packet, 0, dataNew.count, OCFunction.getByte(dataNew))
//        let destination = MIDIEntityGetDestination(_entity, 0)
//        let dd = MIDISend(_outputPort, destination, packetList)
//        if dd == 0 {
//            print("发送成功")
//        }
    
//    func didChangeStatus(notification: UnsafePointer<MIDINotification>) {
//
//        guard notification.pointee.messageID == .msgObjectAdded || notification.pointee.messageID == .msgObjectRemoved || notification.pointee.messageID == .msgPropertyChanged else {
//            return
//        }
//        var usbDevice: MIDIDeviceRef? = nil
//        var bleDevice: MIDIDeviceRef? = nil
//        var isUsb = false
//        var isBle = false
//
//        let lastConnectType = _connectType
//        for index in 0..<MIDIGetNumberOfDevices() {
//            let device = MIDIGetDevice(index)
//            var dict: Unmanaged<CFPropertyList>?
//            MIDIObjectGetProperties(device, &dict, true)
//            print(dict)
//            let dic = dict?.takeRetainedValue() as! [String: Any]
//            print(dic)
////            if dic["offline"] as! Int == 0 {
////                if dic["USBLocationID"] != nil {
////                    usbDevice = device
////                    isUsb = true
////                }else if dic["BLE MIDI Device UUID"] != nil {
////                    bleDevice = device
////                    isBle = true
////                }else{
////                    continue
////                }
//            if dic["offline"] as! Int == 0 && (dic["USBLocationID"] != nil || dic["BLE MIDI Device UUID"] != nil) {
//                for index in 0..<MIDIDeviceGetNumberOfEntities(device) {
//                    let entity = MIDIDeviceGetEntity(device, index)
//                    for indexx in 0..<MIDIEntityGetNumberOfSources(entity) {
//                        let source = MIDIEntityGetSource(entity, indexx)
//                        let status = MIDIPortConnectSource(_inputPort, source, nil)
//                        if status == 0 {
////                            linkSucced = true
//                            _entity = entity
//                            break
//                        }
//                    }
//                }
//            }
//            }
//
////        var linkDevice: MIDIDeviceRef?
////        if isUsb {
////            linkDevice = usbDevice
////            _connectType = .usb
////        }else if isBle {
////            linkDevice = bleDevice
////            _connectType = .ble
////        }else{
////            _connectType = .noml
////        }
////        var linkSucced = false
////        if let linkDevice = linkDevice {
////            for index in 0..<MIDIDeviceGetNumberOfEntities(linkDevice) {
////                let entity = MIDIDeviceGetEntity(linkDevice, index)
////                for indexx in 0..<MIDIEntityGetNumberOfSources(entity) {
////                    let source = MIDIEntityGetSource(entity, indexx)
//////                    let status = MIDIPortConnectSource(_inputPort, source, nil)
//////                    if status == 0 {
//////                        linkSucced = true
//////                        break
//////                    }
////                    OCFunction.connect(_inputPort, source: source)
////                }
////            }
////        }
////        if !linkSucced {
////            _connectType = .noml
////        }
////        self.提示(lastConnectType: lastConnectType)
//    }
//
//    func 提示(lastConnectType: ConnectType) {
//        if 提示 {
//            提示 = false
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
//                self.提示 = true
//            })
//            //提示
//            if lastConnectType != _connectType {
//
//            }
//        }
//    }
    
//    func receiveMessage(message: UnsafePointer<MIDIPacketList>) {
//        OCFunction.myMIDIReadProc(message) {[unowned self] (data) in
//            if let dele = self.delegate {
//                var backData: [UInt8] = []
////                backData = data as! [UInt8]
//                print("未完成")
//                dele.收到MIDI数据(array: backData)
//            }
//        }
//    }


//ItemCount deviceCount = MIDIGetNumberOfDevices();
////    BOOL tagIsLink = _isConnect;
//_isConnect = NO;
//for (int i = 0; i != deviceCount; i++) {
//    MIDIDeviceRef device = MIDIGetDevice(i);
//    NSDictionary *dict = nil;
//    MIDIObjectGetProperties(device, (CFPropertyListRef)&dict, YES);
//    NSLog(@"%@",dict);
//    if (dict[@"USBLocationID"] != nil && [[dict objectForKey:@"offline"] intValue] == 0) {//[dict[@"name"] isEqualToString:@"LePianoT0000052"]){//
//        NSLog(@"发现USB在线设备");
//        ItemCount entitesCount = MIDIDeviceGetNumberOfEntities(device);
//        for (int j = 0; j != entitesCount; j++) {
//            MIDIEntityRef entity = MIDIDeviceGetEntity(device, 0);
//            ItemCount sourceCount = MIDIEntityGetNumberOfSources(entity);
//            for (int k = 0; k != sourceCount; k++) {
//                MIDIEndpointRef source = MIDIEntityGetSource(entity, k);
//                OSStatus statuc = MIDIPortConnectSource(_inputPort, source, NULL);
//                if (statuc == 0) {
//                    _isConnect = YES;
//                    _entity = entity;
//                    break;
//                }
//            }
//            if (_isConnect) {
//                break;
//            }
//        }
//        if (_isConnect) {
//            break;
//        }
//    }
//}
//
//if (_isConnect == YES) {
//    [self sendUsbConnectMessage];
//    NSLog(@"连接成功攻");
//}else{
//    [self sendUsbConnectMessage];
//    NSLog(@"连接失败败");
//}

