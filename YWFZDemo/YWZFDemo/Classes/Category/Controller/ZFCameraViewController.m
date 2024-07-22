//
//  ZFCameraViewController.m
//  ZZZZZ
//
//  Created by YW on 15/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCameraViewController.h"
#import "ZFCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "Constants.h"
#import "ZFAppsflyerAnalytics.h"

@interface ZFCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) ZFCameraView                  *cameraView;
@property (nonatomic, strong) dispatch_queue_t              sessionQueue;
@property (nonatomic, strong) AVCaptureSession              *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput          *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput     *stillImageOutPut;
@end

@implementation ZFCameraViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.sessionQueue = dispatch_queue_create("com.ZZZZZ.captureSession", DISPATCH_QUEUE_SERIAL);
    if (TARGET_IPHONE_SIMULATOR) {
        ShowAlertView(@"提示", @"模拟器不支持拍照", nil, nil, @"确认", ^(id cancelTitle) {
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    
    [self.view addSubview:self.cameraView];
    [self.cameraView.layer insertSublayer:self.previewLayer atIndex:0];
    [self configureSession];
    [self startSession];
    
    if (!ZFIsEmptyString(self.phtotTipString)) {
        [self.cameraView updateTipLabel:self.phtotTipString];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notification
- (void)appDidBecomeActive:(NSNotification *)notification {
    [self startSession];
}

#pragma mark - Private method
- (void)configureSession { 
    [self.session beginConfiguration];
    
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    
    if ([self.session canAddOutput:self.stillImageOutPut]) {
        [self.session addOutput:self.stillImageOutPut];
    }
    
    [self.session commitConfiguration];
    
    if ([self.deviceInput.device lockForConfiguration:nil]) {
//        if ([self.deviceInput.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
//            [self.deviceInput.device setFlashMode:AVCaptureFlashModeAuto];
//        }
        //自动白平衡
        if ([self.deviceInput.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.deviceInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.deviceInput.device unlockForConfiguration];
    }
}

- (void)startSession {
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)stopSession {
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)focusAtPoint:(CGPoint)point{
    BOOL supported = [self.deviceInput.device isFocusPointOfInterestSupported] && [self.deviceInput.device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    if (supported){
        NSError *error;
        if ([self.deviceInput.device lockForConfiguration:&error]) {
            self.deviceInput.device.focusPointOfInterest = point;
            self.deviceInput.device.focusMode = AVCaptureFocusModeAutoFocus;
            [self.deviceInput.device unlockForConfiguration];
        }
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    if ([self.deviceInput.device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([self.deviceInput.device lockForConfiguration:&error]) {
            self.deviceInput.device.torchMode = torchMode;
            [self.deviceInput.device unlockForConfiguration];
        }
    }
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)cameraToggle {
    AVCaptureDevice *currentDevice = [self.deviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    //移除原有输入对象
    [self.session removeInput:self.deviceInput];
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.deviceInput = toChangeDeviceInput;
        
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.layer addAnimation:animation forKey:@"flip"];

    }
    //提交会话配置
    [self.session commitConfiguration];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

- (void)takePictureImage {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    
    [self.stillImageOutPut captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *sourceImage = [UIImage imageWithData:jpegData];
        if (self.photoBlock) {
            self.photoBlock(sourceImage);
        }
        if (self.isReturnSourceVC) {
            
            [self goBackAction];
        } else {
            [self pushToViewController:@"ZFSearchMapPageViewController"
                           propertyDic:@{@"sourceImage" : sourceImage,
                                         @"sourceType"  : @(ZFAppsflyerInSourceTypeSearchImageCamera)
                           }];
        }
    }];
}

- (void)goBackAction {
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self){
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showAlbum {
     @weakify(self)
    [LBXPermission authorizeWithType:LBXPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        @strongify(self)
        if (granted) {
            [self openLocalPhoto];
        }
        else if (!firstTime) {
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"" msg:[NSString stringWithFormat:ZFLocalizedString(@"photoPermisson", nil),[LBXPermission queryAppName]] cancel:ZFLocalizedString(@"Cancel", nil) setting:ZFLocalizedString(@"Setting_VC_Title", nil)];
        }
    }];
}

- (void)openLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.translucent = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self pushToViewController:@"ZFSearchMapPageViewController"
                   propertyDic:@{@"sourceImage" : sourceImage,
                                 @"sourceType"  : @(ZFAppsflyerInSourceTypeSearchImagePhotos)
                                 }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self startSession];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter
- (ZFCameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[ZFCameraView alloc] initWithFrame:self.view.bounds];
        @weakify(self)
        // 聚焦
        _cameraView.focusHandler = ^(CGPoint point) {
            @strongify(self)
            CGPoint devicePoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
            [self focusAtPoint:devicePoint];
        };
        
        // 返回
        _cameraView.backHandler = ^{
            @strongify(self)
            [self goBackAction];
        };
        
        // 手电筒
        _cameraView.flashButtonHandler = ^(UIButton *sender) {
            @strongify(self)
            [self setTorchMode:sender.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        };
        
        // 切换镜头
        _cameraView.toggleButtonHandler = ^{
            @strongify(self)
            [self cameraToggle];
        };
        
        // 拍照
        _cameraView.photoButtonHandler = ^{
            @strongify(self)
            [self takePictureImage];
        };
        
        // 相册
        _cameraView.albumButtonHandler = ^{
            @strongify(self)
            [self showAlbum];
        };
    }
    return _cameraView;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            _session.sessionPreset = AVCaptureSessionPresetPhoto;
        }
    }
    return _session;
}

- (AVCaptureDeviceInput *)deviceInput {
    if (!_deviceInput) {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        if (error) { YWLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription); }
    }
    return _deviceInput;
}

- (AVCaptureStillImageOutput *)stillImageOutPut {
    if (!_stillImageOutPut) {
        _stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG}; //输出设置
        [_stillImageOutPut setOutputSettings:outputSettings];
    }
    return _stillImageOutPut;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.bounds;
    }
    return _previewLayer;
}

@end
