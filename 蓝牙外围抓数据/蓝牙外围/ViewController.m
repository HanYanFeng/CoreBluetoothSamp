//
////  ViewController.m
////  OSBluetooth
////
////  Created by Apple on 17/2/6.
////  Copyright © 2017年 com.guojian. All rights reserved.
////http://blog.sina.com.cn/s/blog_8d1bc23f0102vos2.html

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong , nonatomic) CBPeripheralManager * peripheralManager;
@property (nonatomic, strong) NSMutableData *data;
@property (nonnull , strong) CBMutableCharacteristic * customCharacteristic;
@property (nonnull , strong) CBMutableService * customService;
@property (nonnull ,strong) CBCentral * center;
@property (weak, nonatomic) IBOutlet UITextView *TextView;
@end

@implementation ViewController
static NSInteger a = 0;
- (IBAction)sendAction:(id)sender {
    a++;
    NSString * str = [NSString stringWithFormat:@"第%zd次发送数据，内容为%@",a,self.textField.text];
    NSData * da = [str dataUsingEncoding:NSUTF8StringEncoding];
peripheralManager:central:didSubscribeToCharacteristic:
    //    *  @see                     peripheralManager:central:didSubscribeToCharacteristic:
//    *  @see                    peripheralManager:central:didUnsubscribeFromCharacteristic:
//    *  @see                    peripheralManagerIsReadyToUpdateSubscribers:
//    *	@seealso				maximumUpdateValueLength
    if (self.center != nil) {
        [self.peripheralManager updateValue:da forCharacteristic:self.customCharacteristic onSubscribedCentrals:@[self.center]];
    }else{
        
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.peripheralManager = [self cmgr];
    
}
//1.建立一个Central Manager实例进行蓝牙管理

-(CBPeripheralManager *)cmgr
{
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{@"key":@"valur"}];
        
    }
    
    return _peripheralManager;
}
static NSString * const kServiceUUID = @"03B80E5A-EDE8-4B33-A751-6CE34EC4C700";
static NSString * const kCharacteristicUUID = @"7772E5DB-3868-4112-A1A9-F2669D106BF3";

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
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
                       //蓝牙开启后可把服务添加到周边上
            CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
            // Creates the characteristic
            self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:
                                         characteristicUUID properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions: CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
            // Creates the service UUID
            CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
            // Creates the service and adds the characteristic to it
            self.customService = [[CBMutableService alloc] initWithType:serviceUUID
                                                                primary:YES];
            // Sets the characteristics for this service
            [self.customService setCharacteristics:@[self.customCharacteristic]];
            // Publishes the service
            [self.peripheralManager addService:self.customService];
//            添加成功后会调用peripheralManager:didAddService:error:

        }
            break;
        default:
            break;
    }
}
//添加服务后 会执行此方法 如果没有error 可广播服务
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(nonnull CBService *)service error:(nullable NSError *)error{
    if (error == nil) {
        [self.peripheralManager startAdvertising:@{
                                                   CBAdvertisementDataLocalNameKey:@"bleText"
                                                   ,CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUUID]]
                                                   }];
//        广播后会调用下面的方法
//        -peripheralManagerDidStartAdvertising:error:
    }
}
//        广播后会调用下面的方法
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
        NSLog(@"广播失败");
    }else{
        NSLog(@"广播成功");
    }
}
//并且当中央预定了这个服务，他的代理接收   这儿是你给中央生成动态数据的地方。
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    self.center = central;
}



/*!
 *  @method peripheralManager:willRestoreState:
 *
 *  @param peripheral	The peripheral manager providing this information.
 *  @param dict			A dictionary containing information about <i>peripheral</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *						Bluetooth system.
 *
 *  @seealso            CBPeripheralManagerRestoredStateServicesKey;
 *  @seealso            CBPeripheralManagerRestoredStateAdvertisementDataKey;
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict{
    NSLog(@"当设备重新被系统唤醒的时候调用");
}


/*!
 *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were disabled.
 *
 *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
 *
 */
//当中心设备调用此方法是[peripheral setNotifyValue:NO forCharacteristic:characteristic];下面的方法会被调用
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"中心设备取消了订阅这个服务");
}

/*!
 *  @method peripheralManager:didReceiveReadRequest:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param request      A <code>CBATTRequest</code> object.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
 *
 *  @see                CBATTRequest
 *
 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSData * strig = [@"dsdsdddddd" dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%s",__func__);
    NSLog(@"外围设备收到一个度的请求");
    [peripheral updateValue:strig forCharacteristic:(CBMutableCharacteristic*)request.characteristic onSubscribedCentrals:@[request.central]];
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/*!
 *  @method peripheralManager:didReceiveWriteRequests:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
 *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
 *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    NSLog(@"外围设备收到中央设备写特征值的请求会调用此方法，改完后得回复");
    CBATTRequest * aTTRequest = requests.firstObject;
    
    NSString * string = [NSString stringWithFormat:@"\n%@",aTTRequest.value];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.TextView.textStorage beginEditing];
        [self.TextView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        [self.TextView.textStorage endEditing];
        [self.TextView scrollRangeToVisible: NSMakeRange(self.TextView.text.length, 0)];
    });
    
    //当中央设备发起写的请求时 可以选择是否回复 但是这里我不知道怎么判断是否中央设备需要回复
    [peripheral respondToRequest:aTTRequest withResult:CBATTErrorSuccess];

};

/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 
 Invoked when a local peripheral device is again ready to send characteristic value updates.
 When a call to the updateValue:forCharacteristic:onSubscribedCentrals: method fails because the underlying queue used to transmit the updated characteristic value is full, the peripheralManagerIsReadyToUpdateSubscribers: method is invoked when more space in the transmit queue becomes available. You can then implement this delegate method to resend the value.
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    NSLog(@"当传送队列满了的时候updateValue:forCharacteristic:onSubscribedCentrals就不起作用了，队列有位置的时候会调用次放法，重新传递");
}


@end
