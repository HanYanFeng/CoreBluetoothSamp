//
//  OCFunction.h
//  琴加
//
//  Created by 韩艳锋 on 2017/5/17.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface OCFunction : NSObject
+(NSString*)logObjectPropertys:(id)obj;
+(NSString*)getAppversion;
+(BOOL)checkDevice;
+(UIViewController*)currentViewController;
///展示信息带按钮的
+(void)showMessageWithAlert:(NSString*)message;


+(NSData*)playNote:(UInt8)pitch velocity:(UInt8)velocity channel:(UInt8)channel;

+(void)logStr:(id)string;

+(NSString*)getQuanPin:(NSString*)string;

+(BOOL)judgeIsPhoneNumber:(NSString*)str;
+ (void)shareImageTo;
+ (Byte *)getByte:(NSData*)data;

+ (BOOL)isDebug;
// 返回项目的名字
@end
///返回颜色
UIColor * colorWithHexString(NSString * color, CGFloat alpha);

