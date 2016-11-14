//
//  ScanViewController.m
//  QRCodeScan
//
//  Created by wenyou on 2016/10/8.
//  Copyright © 2016年 wenyou. All rights reserved.
//

#import "ScanViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Masonry/Masonry.h>
#import "ShadowView.h"
#import "UsageUtility.h"
#import "HistoryDataCache.h"


@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end


@implementation ScanViewController {
    AVCaptureDevice *_device;
    AVCaptureSession *_session;
    UIView *_bgView;
    UIButton *_lightButton;
    BOOL _supportCamera;
    BOOL _hasAlert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.hidden = YES;
    [self.view addSubview:_bgView];
    
    ShadowView *shadowView = [[ShadowView alloc] initWithFrame:self.view.bounds];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:shadowView];
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imgButton.layer.cornerRadius = 20;
    imgButton.clipsToBounds = YES;
    imgButton.titleLabel.font = [TLIconfont fontOfSize:20];
    imgButton.backgroundColor = [UIColor colorWithHexValue:0x000000 alpha:32];
    [imgButton setTitle:@"\uf03e" forState:UIControlStateNormal];
    [imgButton addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:imgButton];
    [imgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(shadowView).offset(-20);
        make.bottom.equalTo(shadowView).offset(- 20 - 48);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _lightButton.layer.cornerRadius = 20;
    _lightButton.clipsToBounds = YES;
    _lightButton.titleLabel.font = [TLIconfont fontOfSize:20];
    _lightButton.backgroundColor = [UIColor colorWithHexValue:0x000000 alpha:32];
    [_lightButton setTitle:@"\uf0e7" forState:UIControlStateNormal];
    [_lightButton addTarget:self action:@selector(LightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:_lightButton];
    [_lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imgButton.mas_left).offset(-20);
        make.bottom.equalTo(imgButton);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_hasAlert) {
        _supportCamera = [UsageUtility isCameraAvailable] && [UsageUtility isAVAuthorization];
    } else {
        _supportCamera = [UsageUtility checkCamera:self];
    }
    _bgView.hidden = _supportCamera;
    _lightButton.hidden = !_supportCamera;
    
    
    if (_supportCamera) {
        [self initDevice];
        
        [self setLightButtonStyle];
        [_session startRunning];
    } else {
        _hasAlert = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_session stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!metadataObjects.count) {
        return;
    }
    [_session stopRunning];
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    [[HistoryDataCache sharedInstance] addCacheValue:metadataObject.stringValue];
    [ScanViewController handleValue:metadataObject.stringValue
                 withViewController:self
                           endBlock:^(){
                               [_session startRunning];
                           }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *pickImage = info[UIImagePickerControllerEditedImage]; // UIImagePickerControllerOriginalImage
//        CIImage *ciImage = pickImage.CIImage; // 这种方式不行, why?
        CIImage *ciImage = [CIImage imageWithData:UIImagePNGRepresentation(pickImage)];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSArray *features = [detector featuresInImage:ciImage]; //创建探测器
        if (features.count) {
            CIQRCodeFeature *feature = [features firstObject]; //取出探测到的数据
            [[HistoryDataCache sharedInstance] addCacheValue:feature.messageString];
            [ScanViewController handleValue:feature.messageString withViewController:self endBlock:nil];
        } else {
            [self presentViewController:({
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"该图片识别不出二维码"
                                                                                    message:nil
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                controller;
            }) animated:YES completion:nil];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private
- (void)initDevice {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:([UIScreen mainScreen].bounds.size.height < 500) ? AVCaptureSessionPreset640x480 : AVCaptureSessionPresetHigh];
        [_session addInput:input];
        [_session addOutput:output];
        
        CGSize windowSize = [UIScreen mainScreen].bounds.size;
        CGSize scanSize = CGSizeMake(windowSize.width - 100, windowSize.width - 100);
        CGRect scanRect = CGRectMake((windowSize.width - scanSize.width) / 2, (windowSize.height-scanSize.height) / 2, scanSize.width, scanSize.height);
        scanRect = CGRectMake(scanRect.origin.y / windowSize.height, scanRect.origin.x / windowSize.width, scanRect.size.height / windowSize.height, scanRect.size.width / windowSize.width);   // 计算rectOfInterest 注意x, y交换位置
        output.rectOfInterest = scanRect;
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.frame = [UIScreen mainScreen].bounds;
        [self.view.layer insertSublayer:layer atIndex:0];
    }
}

- (void)setLightButtonStyle {
    switch (_device.torchMode) {
        case AVCaptureTorchModeOn:
            [_lightButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            break;
        case AVCaptureTorchModeOff:
            [_lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        case AVCaptureTorchModeAuto:
            [_lightButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)LightButtonClicked:(id)sender {
    [_device lockForConfiguration:nil];
    switch (_device.torchMode) {
        case AVCaptureTorchModeOn:
            _device.torchMode = AVCaptureTorchModeOff;
            break;
        case AVCaptureTorchModeOff:
            _device.torchMode = AVCaptureTorchModeOn;
            break;
        case AVCaptureTorchModeAuto:
            _device.torchMode = AVCaptureTorchModeOn;
            break;
        default:
            break;
    }
    [_device unlockForConfiguration];
    [self setLightButtonStyle];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (_supportCamera) {
        [_session startRunning];
    }
}

- (void)imageButtonClicked:(id)sender {
    if ([UsageUtility checkPhoto:self]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        // UIImagePickerControllerSourceTypePhotoLibrary        相册
        // UIImagePickerControllerSourceTypeCamera              相机
        // UIImagePickerControllerSourceTypeSavedPhotosAlbum    照片库
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  // 资源来源
        controller.allowsEditing = YES; // 编辑
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;  // 转场动画
//        [self.navigationController pushViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

+ (void)handleValue:(NSString *)value withViewController:(UIViewController *)viewController endBlock:(SimpleBlockNoneParameter)endBlock {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);    
    [viewController presentViewController:({
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:value message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:value]]) {
            [controller addAction:[UIAlertAction actionWithTitle:@"用浏览器打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:value]];
            }]];
        }
        [controller addAction:[UIAlertAction actionWithTitle:@"拷贝到剪贴板" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:value];
            if (endBlock) {
                endBlock();
            }
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (endBlock) {
                endBlock();
            }
        }]];
        controller;
    })animated:YES completion:nil];
}
@end
