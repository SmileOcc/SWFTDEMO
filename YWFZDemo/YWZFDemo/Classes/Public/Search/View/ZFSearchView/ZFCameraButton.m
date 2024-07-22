//
//  ZFCameraButton.m
//  ZZZZZ
//
//  Created by YW on 2018/9/27.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCameraButton.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface ZFCameraButton()

@property (nonatomic, strong) UIView *cameraView;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession           *session;
@property (nonatomic, strong) AVCaptureDeviceInput          *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput     *stillImageOutPut;

@end

@implementation ZFCameraButton

- (void)dealloc {
    if ([self checkCameraPermission]) {
        [self stopSession];
    }
}

- (void)setCamera {
    if ([self checkCameraPermission]) {
        [self.layer insertSublayer:self.previewLayer atIndex:0];
        self.previewLayer.frame = self.bounds;
        [self configureSession];
        [self startSession];
    }
}

- (UIView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[UIView alloc] init];
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

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
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

- (BOOL)checkCameraPermission {
    if (TARGET_IPHONE_SIMULATOR) {
        YWLog(@"模拟器不支持拍照");
        return NO;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

@end
