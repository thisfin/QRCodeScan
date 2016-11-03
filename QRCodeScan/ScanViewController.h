//
//  ScanViewController.h
//  QRCodeScan
//
//  Created by wenyou on 2016/10/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^SimpleBlockNoneParameter)();
typedef void(^SimpleBlock)(id data);


@interface ScanViewController : UIViewController
+ (void)handleValue:(NSString *)value withViewController:(UIViewController *)viewController endBlock:(SimpleBlockNoneParameter)endBlock;
@end
