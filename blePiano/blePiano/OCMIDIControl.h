//
//  OCUSBControl.h
//  琴加
//
//  Created by 韩艳锋 on 2017/10/26.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

typedef NS_ENUM(NSInteger, MIDIDeviceConnectStatus) {
    Norml  = 0,
    Bluetooth    = 1,
    Usb  = 2
};

@interface OCMIDIControl : NSObject{
    MIDIClientRef   _client;
    MIDIPortRef     _inputPort;
    MIDIPortRef     _outputPort;
    MIDIEntityRef   _entity;
    MIDIEndpointRef _lastSource;
    MIDIDeviceConnectStatus _connectStatus;
}
@property (nonatomic, readonly, assign) BOOL isConnect;
@property (nonatomic, readonly, assign) BOOL isUsb;
/**
 收到数据回调
 */
@property (copy, readonly) void(^back)(NSData*);

/**
 连接变化回调
 */
@property (copy) void(^connectChange)(void);

/**
 通知用户回调
 */
@property (copy) void(^message)(NSString*);

/**
 发送MDID数据

 @param data 要发的数据
 */
- (void)sendMIdiData:(NSData*)data;

/**
 初始化

 @param back 收到数据回调
 @return instancetype
 */
- (instancetype)initWithBack:(void(^)(NSData*))back;

/**
 应用进入前台更新连接状态
 */
- (void)refreshConnectStatus;

@end
