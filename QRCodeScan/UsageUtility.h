//
//  UsageUtility.h
//  QRCodeScan
//
//  Created by wenyou on 2016/10/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsageUtility : NSObject
+ (BOOL)isCameraAvailable;
+ (BOOL)isAVAuthorization;
+ (BOOL)isPHAuthorization;
+ (BOOL)checkCamera:(UIViewController *)controller;
+ (BOOL)checkPhoto:(UIViewController *)controller;
@end
