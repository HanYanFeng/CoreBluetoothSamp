//
//  OCFunction.m
//  琴加
//
//  Created by 韩艳锋 on 2017/5/17.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import "OCFunction.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

@implementation OCFunction

+(BOOL)checkDevice
{
    NSString* deviceType = [UIDevice currentDevice].model;
//    NSLog(@"deviceType = %@", deviceType);
    
    NSRange range = [deviceType rangeOfString:@"iPad"];
    return !(range.location != NSNotFound);
}
///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
+(NSArray*)allPropertyNames:(id)object{
    ///存储所有的属性名称
    NSMutableArray*allNames=[[NSMutableArray alloc]init];
    
    ///存储属性的个数
    unsigned propertyCount=0;
    
    ///通过运行时获取当前类的属性
    objc_property_t*propertys=class_copyPropertyList([object class],&propertyCount);
    
    //把属性放到数组中
    for(int i=0;i<propertyCount;i++){
        ///取出第一个属性
        objc_property_t property=propertys[i];
        
        const char*propertyName=property_getName(property);
        
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    ///释放
    free(propertys);
    
    return allNames;
}




+(NSData*)playNote:(UInt8)pitch velocity:(UInt8)velocity channel:(UInt8)channel;
{
    static const Byte noteOn = 0x90;
    Byte byte[3];
    byte[0] = noteOn + channel;
    byte[1] = pitch;
    byte[2] = velocity;
    UInt8 * data = byte;
    static const UInt8 bytee[2] = {0x80, 0x80};
    size_t length = 3 + 2;
    UInt8* dataBytes = alloca(sizeof(UInt8) * length);
    memcpy(dataBytes, bytee, 2);
    memcpy(&dataBytes[2], data, 3);
    return [NSData dataWithBytes:dataBytes length:length];
}
+(void)logStr:(id)string;
{
    NSLog(@"%@",string);
}

+(NSString*)getQuanPin:(NSString*)string{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:string];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    return str;
}
+(NSString*)logObjectPropertys:(id)obj;
{
    NSArray * arr = [self allPropertyNames:obj];
    NSMutableString * string = [NSMutableString string];
    for (NSString * str  in arr) {
        [string appendFormat:@"%@: %@ ",str,[obj valueForKey:str]];
    }
    return string;
}

+(NSString*)getAppversion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+(BOOL)judgeIsPhoneNumber:(NSString*)str{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}



+(void)showMessageWithAlert:(NSString*)message;
{
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:action];
    [[self currentViewController] presentViewController:vc animated:YES completion:nil];
}


//获取Window当前显示的ViewController
+(UIViewController*)currentViewController{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    
    return vc;
}


+ (void)MyMIDIReadProc:(const MIDIPacketList *)packetList back:(void(^)(NSData * data))back;
{
    MIDIPacket * packet = &(packetList->packet[0]);
    NSMutableString * string = [NSMutableString string];
    for (int i = 0; i < packetList->numPackets; i++) {
        const Byte * msg = packet->data;
        for (int j = 0; j != packet->length; j++) {
            [string appendFormat:@"%d ",msg[j]];
        }
        back([NSData dataWithBytes:packet->data length:packet->length]);
        [string appendString:@" -- "];
        packet = MIDIPacketNext(packet);
    }
    NSLog(@"%@",string);
}
+ (Byte *)getByte:(NSData*)data{
    return (Byte *)data.bytes;
}

+ (BOOL)isDebug;
{
    return DEBUG == 1;
}

@end
UIColor * colorWithHexString(NSString *color , CGFloat alpha)
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
