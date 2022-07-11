//
//  STLRequestAccessory.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLRequestAccessory.h"

@interface STLRequestAccessory ()

@property (nonatomic,weak) MBProgressHUD *hud;

///因为这里能获取到的view,一般都是来自于UIViewController的view, controller的view是被controller强引用的，所以当controller不被释放，这个视图是不会被释放的
@property (nonatomic,weak) UIView *view;
@property (nonatomic,assign) BOOL   enable;

@end

@implementation STLRequestAccessory

- (instancetype)initWithApperOnView:(UIView *)view {
    if (self = [super init]) {
        _view = view;
    }
    return self;
}

- (instancetype)initWithApperOnView:(UIView *)view isEnable:(BOOL)enable{
    if (self = [super init]) {
        _view = view;
        _enable = enable;
    }
    return self;
}

- (void)requestStart:(id)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_view ? _view : [UIApplication sharedApplication].keyWindow animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        if (![OSSVNSStringTool isEmptyString:self.title]) {
            hud.detailsLabel.text = self.title;
        } else {
            //        hud.labelText = @"Loading...";
        }
        // 改变背景框颜色
        hud.bezelView.color = [UIColor clearColor];
        // 设置模式
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = !self.enable;
        self.hud = hud;
    });
}

- (void)requestStop:(id)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hideAnimated:YES];
    });
}
@end
