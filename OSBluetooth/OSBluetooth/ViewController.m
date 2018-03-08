//
//  ViewController.m
//  Bluetooth
//
//  Created by Apple on 17/2/6.
//  Copyright © 2017年 com.guojian. All rights reserved.http://blog.sina.com.cn/s/blog_8d1bc23f0102vos2.html
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong ,nonatomic) CBPeripheral * peripheral;
@property (strong ,nonnull) CBCharacteristic * custemPeripheral;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSMutableData * data;

@property (weak) IBOutlet NSTextField *receiveLable;
@property (weak) IBOutlet NSTextField *toSendDate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [self cmgr];
    
}
static NSInteger a = 0;
- (IBAction)btnTouch:(id)sender {
    a++;
    NSString * str = [NSString stringWithFormat:@"中心向外围第%zd次发送消息，内容为：%@",a,self.toSendDate.stringValue];
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.custemPeripheral type:CBCharacteristicWriteWithResponse];
}

-(CBCentralManager *)cmgr
{
    if (!_manager) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _manager;
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
            
        }
            break;
        case 5:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            // 在中心管理者成功开启后再进行一些操作
            // 搜索外设
            [self.manager scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                              options:nil]; // dict,条件
            // 搜索成功之后,会调用我们找到外设的代理方法
            // - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设
        }
            break;
        default:
            break;
    }
}

// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"%@ %@",peripheral,advertisementData);
    // Stops scanning for peripheral
    if (self.peripheral != peripheral && [advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString:@"bleText"]) {
        [self.manager stopScan];
        self.peripheral = peripheral;
        NSLog(@"Connecting to peripheral %@", peripheral);
        // Connects to the discovered peripheral
        [self.manager connectPeripheral:peripheral options:nil];
    }
}
static NSString * const kServiceUUID = @"B69FB353-645A-4EF2-AF89-AACAD90F6C42";
static NSString * const kCharacteristicUUID = @"A018E3E9-2157-43EA-9908-91F97303743A";
//连接成功后会调用此方法  连接失败会调用失败的方法
static NSTimer * timer = nil;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    NSLog(@"%s",__func__);
    NSLog(@"中心设备：我已经连接外围设备%@",peripheral);
//  [central stopScan];
    [self.peripheral setDelegate:self];
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(look) userInfo:nil repeats:YES];

     [self.peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}


-(void)look{
    [self.peripheral readRSSI];
}

/*!
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(10_9, 6_0){
    NSLog(@"中心设备更新了名字");
}

/*!
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 *
 *	@deprecated			Use {@link peripheral:didInvalidateServices:} instead.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_DEPRECATED(NA, NA, 6_0, 7_0){
    
}

/*!
 *  @method peripheral:didModifyServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *  @param invalidatedServices		The services that have been invalidated
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
 *						At this point, the designated <code>CBService</code> objects have been invalidated.
 *						Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(10_9, 7_0){
    
}

/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"外设更新了距离新的距离为%@",peripheral.RSSI);
}

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    if (error) {
        NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error{
    
    NSLog(@"%s",__func__);
    if (error) {
        
        NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"B69FB353-645A-4EF2-AF89-AACAD90F6C42"]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"A018E3E9-2157-43EA-9908-91F97303743A"]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    if (error) {
        NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"B69FB353-645A-4EF2-AF89-AACAD90F6C42"]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"A018E3E9-2157-43EA-9908-91F97303743A"]]) {
                //订阅一个特征
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
                //读取一个特征值
                [peripheral readValueForCharacteristic:characteristic];
                self.custemPeripheral = characteristic;
            }
        }
    }
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    
//    if (error) {
//        NSLog(@"Error changing notification state:%@", error.localizedDescription);
//    }
    self.receiveLable.stringValue = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    // Exits if it's not the transfer characteristic
//    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
//        return;
//    }
//    // Notification has started
//    if (characteristic.isNotifying) {
//        NSLog(@"Notification began on %@", characteristic);
//        NSLog(@"%@",[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
//        //                  [peripheral readValueForCharacteristic:characteristic];
//    } else { // Notification has stopped
//        // so disconnect from the peripheral
//        NSLog(@"Notification stopped on %@.Disconnecting", characteristic);
//        //                        [self.manager cancelPeripheralConnection:self.peripheral];
//    }
    if (error == nil) {
        NSLog(@"中心设备读取特征值成功或中心设备收到外围设备的修改特征值");//在这里怎么区分我也不清楚
    }else{
        NSLog(@"中心设备读取特征值失败原因是%@",error.localizedDescription);
    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    if (error == nil) {
        NSLog(@"中心成功修改了特征值");
    }else{
        NSLog(@"中心成功修改了特征值%@", error.localizedDescription);
    }
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"外设更新了特征的状态通知状态");
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"中心发现了特征的描述");
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"外围更新了描述");
}

/*!
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"中心成功修改周边的描述");
}



/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param central      The central manager providing this information.
 *
 *
 *  *
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dic{
    NSLog(@"%s",__func__);
    NSLog(@"中央管理器将被恢复系统");
};

/*!
 *  @method centralManager:didRetrievePeripherals:
 *
 *  @discussion         This method returns the result of a {@link retrievePeripherals} call, with the peripheral(s) that the central manager was
 *                      able to match to the provided UUID(s).
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray<CBPeripheral *> *)peripherals{
    NSLog(@"%s",__func__);
    NSLog(@"重新搜索设备成功了");
}

/*!
 *
 *  @discussion         This method returns the result of a {@link retrieveConnectedPeripherals} call.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray<CBPeripheral *> *)peripherals{
    NSLog(@"%s",__func__);
    NSLog(@"重新连接成功了");
}
/*!
*  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"连接失败");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"%s",__func__);
    NSLog(@"失去连接");
    self.peripheral = nil;
    [self.manager scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                         options:nil]; // di
//    [central retrieveConnectedPeripherals];
}

@end
