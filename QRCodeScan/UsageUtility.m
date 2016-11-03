//
//  UsageUtility.m
//  QRCodeScan
//
//  Created by wenyou on 2016/10/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "UsageUtility.h"

#import <AVFoundation/AVFoundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>


@implementation UsageUtility
+ (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isAVAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return !(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied);
}

// ios 9-
//+ (BOOL)isALAuthorization {
//    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
//    return !(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied);
//}

+ (BOOL)isPHAuthorization {
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    return !(author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied);
}

+ (BOOL)checkCamera:(UIViewController *)controller {
    if (![UsageUtility isCameraAvailable]) {
        [controller presentViewController:({
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"摄像头不可用"
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            controller;
        }) animated:YES completion:nil];
        return false;
    }
    if (![UsageUtility isAVAuthorization]) {
        [controller presentViewController:({
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"未获得授权使用摄像头"
                                                                                message:@"请在iOS\"设置\"-\"隐私\"-\"相机\"中打开"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            controller;
        }) animated:YES completion:nil];
        return false;
    }
    return true;
}

+ (BOOL)checkPhoto:(UIViewController *)controller {
    if (![UsageUtility isPHAuthorization]) {
        [controller presentViewController:({
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"未获得授权使用照片"
                                                                                message:@"请在iOS\"设置\"-\"隐私\"-\"照片\"中打开"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            controller;
        }) animated:YES completion:nil];
        return false;
    }
    return true;
}
@end
