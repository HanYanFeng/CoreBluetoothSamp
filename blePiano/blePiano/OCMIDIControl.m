//
//  OCUSBControl.m
//  琴加
//
//  Created by 韩艳锋 on 2017/10/26.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import "OCMIDIControl.h"

#import "blePiano-Swift.h"



static OCMIDIControl * control = nil;


@implementation OCMIDIControl
static BOOL send = YES;

- (instancetype)initWithBack:(void(^)(NSData*))back{
    self = [super init];
    if (self) {
//        _back = back;
//        control = self;
//        if (_client != (MIDIObjectRef)NULL) {
//            MIDIClientDispose(_client);
//        }
//        OSStatus status = MIDIClientCreate(CFSTR("client"), MIDIStateChangedHander, (__bridge void *)(self), &_client);
//        if (status != 0) {
//            NSLog(@"创建midi客户端失败");
//        }
//        status = MIDIInputPortCreate(_client, CFSTR("com.win-electr.inputPort"), MyMIDIReadProc, (__bridge void *)(self), &_inputPort);
//        if (status != 0) {
//            NSLog(@"创建输入端失败");
//        }
//        status = MIDIOutputPortCreate(_client, CFSTR("com.win-electr.outputPort"), &_outputPort);
//        if (status != 0) {
//            NSLog(@"创建输出端失败");
//        }
        _connectStatus = Norml;
    }
    return self;
}
- (BOOL)isUsb {
    return _connectStatus == Usb;
}

-(BOOL)isConnect {
    return _connectStatus != Norml;
}

static BOOL reConnect = YES;
- (void)reconnectAllSources{
    if (reConnect) {
        reConnect = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            reConnect = YES;
            [self reConnect];
        });
    }
}

-(void)reConnect {
    ItemCount deviceCount = MIDIGetNumberOfDevices();
    //    BOOL tagIsLink = _isConnect;
    MIDIDeviceConnectStatus last = _connectStatus;
    _connectStatus = Norml;
    for (int i = 0; i != deviceCount; i++) {
        MIDIDeviceRef device = MIDIGetDevice(i);
        NSDictionary *dict = nil;
        MIDIObjectGetProperties(device, (CFPropertyListRef)&dict, YES);
        NSLog(@"%@",dict);
        
        if ((dict[@"USBLocationID"] != nil /*|| dict[@"BLE MIDI Device UUID"] != nil*/) && [[dict objectForKey:@"offline"] intValue] == 0) {//[dict[@"name"] isEqualToString:@"LePianoT0000052"]){//
            NSLog(@"发现USB在线设备");
            ItemCount entitesCount = MIDIDeviceGetNumberOfEntities(device);
            for (int j = 0; j != entitesCount; j++) {
                MIDIEntityRef entity = MIDIDeviceGetEntity(device, 0);
                ItemCount sourceCount = MIDIEntityGetNumberOfSources(entity);
                for (int k = 0; k != sourceCount; k++) {
                    MIDIEndpointRef source = MIDIEntityGetSource(entity, k);
                    NSLog(@"%d",MIDIPortDisconnectSource(_inputPort, _lastSource));
                    _lastSource = source;
                    OSStatus statuc = MIDIPortConnectSource(_inputPort, source, NULL);
                    if (statuc == 0) {
                        if (dict[@"USBLocationID"] != nil) {
                            _connectStatus = Usb;
                            NSLog(@"连接USB");
                        }else{
                            _connectStatus = Bluetooth;
                            NSLog(@"连接蓝牙");
                        }
                        _entity = entity;
                        break;
                    }
                }
                if (_connectStatus == Usb) {
                    break;
                }
            }
            if (_connectStatus == Usb) {
                break;
            }
        }
    }
    
    if (_connectStatus == Norml) {
        NSLog(@"连接失败");
    }
    
    if (last != _connectStatus) {
        // 通知连接状态变化
        self.connectChange();
        if (_connectStatus == Usb) {
            [self sendUsbConnectMessage:@"USB设备已连接"];
        }
    }
}
- (void)sendUsbConnectMessage:(NSString*)mesage {
    if (send) {
        send = NO;
//        [self.swiftDelegete usbLinkChange];
        self.message(mesage);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            send = YES;
        });
    }
}


- (void)sendMIdiData:(NSData*)data{
    
    const Byte * byte = data.bytes;
    NSData * dataNew = nil;
    if ( ( (*byte & 0x80) == 0x80 )&&( (*(byte + 1) & 0x80) == 0x80 ) ) {
        dataNew = [NSData dataWithBytes:byte + 2 length:data.length - 2];
        byte = dataNew.bytes;
    }else{
        dataNew = data;
    }
    //    dataNew = data;
    NSLog(@"%@",dataNew);
    char buffer[256];
    MIDIPacketList *packets = (MIDIPacketList *)buffer;
    MIDIPacket *packet = MIDIPacketListInit(packets);
    
    packet = MIDIPacketListAdd(packets, 256, packet, 0, dataNew.length, byte);
    
    MIDIEndpointRef destination = MIDIEntityGetDestination(_entity, 0);
    OSStatus dd = MIDISend(_outputPort, destination, packets);
    if (dd == 0) {
        NSLog(@"usb发送数据成功");
    }else{
        NSLog(@"——————————————————————————————usb发送数据失败");
    }
}
/**
 应用进入前台更新连接状态
 */
- (void)refreshConnectStatus;
{
//    MIDIDeviceConnectStatus last = _connectStatus;
    send = NO;
    [self reconnectAllSources];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        send = YES;
    });
//    if (last == Norml) {
//        if (_connectStatus == Norml) {
//
//        }else if(_connectStatus == Bluetooth) {
//
//        }else if (_connectStatus == Usb) {
//
//        }
//    }else if(last == Bluetooth) {
//        if (_connectStatus == Norml) {
//
//        }else if(_connectStatus == Bluetooth) {
//
//        }else if (_connectStatus == Usb) {
//
//        }
//    }else if (last == Usb) {
//        if (_connectStatus == Norml) {
//
//        }else if(_connectStatus == Bluetooth) {
//
//        }else if (_connectStatus == Usb) {
//
//        }
//    }
}
static void MIDIStateChangedHander(const MIDINotification *message, void *refCon)
{
    if (message->messageID != kMIDIMsgObjectAdded && message->messageID != kMIDIMsgObjectRemoved) return;
    [control reconnectAllSources];
}
static void MyMIDIReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
    const MIDIPacket *packet = &packetList->packet[0];
    NSMutableString * string = [NSMutableString string];
    for (int i = 0; i < packetList->numPackets; i++) {
        const Byte * msg = packet->data;
        for (int j = 0; j != packet->length; j++) {
            [string appendFormat:@"%d ",msg[j]];
        }
        control.back([NSData dataWithBytes:packet->data length:packet->length]);
        [string appendString:@" -- "];
        packet = MIDIPacketNext(packet);
    }
    NSLog(@"%@",string);
}
@end

