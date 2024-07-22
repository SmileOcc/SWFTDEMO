//
//  ZFPushAllowView.m
//  ZZZZZ
//
//  Created by YW on 30/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPushAllowView.h"
#import "ZFInitViewProtocol.h"
#import "AppDelegate+ZFNotification.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFAppsflyerAnalytics.h"

@interface ZFPushAllowView ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *imageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIButton              *allowButton;
@property (nonatomic, strong) UIButton              *cancleButton;
@property (nonatomic, copy) NSString                *fromType;
@property (nonatomic, copy) void (^completionBlock)(void);
@end

@implementation ZFPushAllowView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame fromType:(NSString *)fromType {
    self = [super initWithFrame:frame];
    if (self) {
        self.fromType = fromType;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        //转换推送View
        [self judgeShowView:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public method

+ (void)showPushAllowViewCompletion:(NSString *)fromType completionBlock:(void(^)(void))completionBlock
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    UIView *oldPushView = [window viewWithTag:kRegisterNotificationViewTag];
    if (oldPushView && [oldPushView isKindOfClass:[ZFPushAllowView class]]) {
        [oldPushView removeFromSuperview];//防止走两次
    }
    
    ZFPushAllowView *pushAllowView = [[ZFPushAllowView alloc] initWithFrame:[UIScreen mainScreen].bounds fromType:fromType];
    pushAllowView.backgroundColor = [UIColor whiteColor];
    pushAllowView.completionBlock = completionBlock;
    pushAllowView.tag = kRegisterNotificationViewTag;
//    pushAllowView.fromType = fromType;
    [window addSubview:pushAllowView];
}

/// APP启动的时候调用的方法
+ (void)AppDidFinishLanuchShowPushAllowView:(void(^)(void))completionBlock
{
    [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        
        if (!isRegister && [self isPopPushViewWhenAppLanuch]) {
            NSString *fromType = @"Startpage";
            [ZFPushAllowView showPushAllowViewCompletion:fromType completionBlock:completionBlock];
            [ZFAppsflyerAnalytics analyticsPushEvent:fromType remoteType:ZFOperateRemotePush_Default];
            
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

/// APP登录注册调用的方法
+ (void)AppLoginRegisterShowPushAllowView:(void(^)(void))completionBlock
{
    [ZFPushManager canShowAlertView:^(BOOL canShow) {
        if (canShow) {
            ///保存显示时间
            [ZFPushManager saveShowAlertTimestamp];
            
            ///保存启动的版本
            NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
            NSString *version = ZFSYSTEM_VERSION;
            version = [version stringByAppendingString:@"LoginRegister"];
            [UD setObject:version forKey:ZFUserLoginRegisterOpenPushAllowView];
            
            NSString *fromType = @"signup";
            [ZFPushAllowView showPushAllowViewCompletion:fromType completionBlock:completionBlock];
            [ZFAppsflyerAnalytics analyticsPushEvent:fromType remoteType:ZFOperateRemotePush_Default];
            
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

#pragma mark - private mtehod

///在当前版本是否已经弹出过推送视图
+(BOOL)isPopPushViewInCurrentVersion
{
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [UD objectForKey:ZFUserLoginRegisterOpenPushAllowView];
    NSString *version = ZFSYSTEM_VERSION;
    version = [version stringByAppendingString:@"LoginRegister"];
    if ([lastVersion isEqualToString:version]) {
        return NO;
    }
    return YES;
}

+(BOOL)isPopPushViewWhenAppLanuch
{
    //只会弹一次
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSString *isPop = [UD objectForKey:@"ZFonePopPushView"];
    if (!isPop) {
        SaveUserDefault(@"ZFonePopPushView", @"YES");
        return YES;
    }
    return NO;
}

-(void)goToSettingPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Action method

- (void)allowButtonAction {
    // 注册远程推送通知
    BOOL isPopAlert = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    if (isPopAlert) {
        //如果已经弹出过，就直接进入到系统推送页面
        [self goToSettingPage];
        [self cancle];
    }else{
        [ZFAppsflyerAnalytics analyticsPushEvent:self.fromType remoteType:ZFOperateRemotePush_guide_yes];
        [AppDelegate registerZFRemoteNotification:^(NSInteger openFlag) {
            // 点击注册推送后立马关掉引导页面
            [self cancle];
            [ZFAnalytics appsFlyerTrackEvent:@"af_subscribe" withValues:@{}];
            
            // 统计推送点击量
            ZFOperateRemotePushType remoteType = ZFOperateRemotePush_sys_unKonw;
            if (openFlag == 1) {
                remoteType = ZFOperateRemotePush_sys_yes;
            } else if (openFlag == 0) {
                remoteType = ZFOperateRemotePush_sys_no;
            }
            [ZFAppsflyerAnalytics analyticsPushEvent:self.fromType remoteType:remoteType];
        }];
    }
}

- (void)cancelButtonAction {
    [self cancle];
    [ZFAppsflyerAnalytics analyticsPushEvent:self.fromType remoteType:ZFOperateRemotePush_guide_no];
}

- (void)cancle {
    //转换推送View
    [self judgeShowView:NO];
    [ZFPushManager saveShowAlertTimestamp];
}

/**
 * 转换推送View
 */
- (void)judgeShowView:(BOOL)show
{
    UIWindow* window = [UIApplication sharedApplication].delegate.window;
    BOOL oldState = [UIView areAnimationsEnabled];
    
    [UIView transitionWithView:window
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [UIView setAnimationsEnabled:NO];
                        
                        if (!show) {
                            [self removeFromSuperview];
                        }
                   } completion:^(BOOL finished) {
                        [UIView setAnimationsEnabled:oldState];
                       
                        if (finished && !show) {
                            if (self.completionBlock) {
                                self.completionBlock();
                            }
                        }
     }];
}

#pragma mark -===========<ZFInitViewProtocol>===========

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.allowButton];
    [self addSubview:self.cancleButton];
}

- (void)zfAutoLayoutView {
    UIImage *image = self.imageView.image;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, image.size.height*ScreenWidth_SCALE));
        make.centerY.mas_equalTo(self.mas_centerY).offset(-80);
    }];
    
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.imageView.mas_bottom).offset(30);
//        make.leading.mas_equalTo(self.mas_leading).offset(20);
//        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
//    }];
    
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(IPHONE_X_5_15 ? 34 : 20));
        make.leading.equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth - 16*2, 40));
    }];
    
    [self.allowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.cancleButton.mas_top).offset(-12);
        make.leading.equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth - 16*2, 40));
    }];
}

/**
 * 获取推送通知背景图
 */
- (UIImage *)fetchNotifycationImage {
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    if (lang.length>2) {
        lang = [lang substringWithRange:NSMakeRange(0, 2)];
        if (lang) {
            lang = [lang lowercaseString];
        }
    }
    if (!lang || [lang isEqualToString:@"ar"]) {
        lang = @"en";
    }
    NSString *imageName = @"guide_PushNotifycation";
    UIImage *notifycationImage = ZFImageWithName([NSString stringWithFormat:@"%@_%@", imageName, lang]);
    
    if (!notifycationImage) {
        notifycationImage = ZFImageWithName(@"guide_PushNotifycation_en");
    }
    
    // 不存在时将启动图片设置为背景图
    if (![notifycationImage isKindOfClass:[UIImage class]]) {
        UIImage *launchImage = [UIImage imageNamed:getLaunchImageName()];
        if ([launchImage isKindOfClass:[UIImage class]]) {
            return launchImage;
        }
    }
    return notifycationImage;
}

#pragma mark - Getter

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        // 获取推送通知背景图
        _imageView.image = [self fetchNotifycationImage];
    }
    return _imageView;
}

// V3.5.0版本不显示了
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = ZFFontBoldSize(20);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = ZFCOLOR_WHITE;
        _titleLabel.text = ZFLocalizedString(@"Guide_PushNotifycation_title",nil);
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UIButton *)allowButton {
    if (!_allowButton) {
        _allowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _allowButton.layer.cornerRadius = 3;
        _allowButton.layer.masksToBounds = YES;
        _allowButton.backgroundColor = ZFC0x2D2D2D();
        _allowButton.titleLabel.font = ZFFontBoldSize(16);
        [_allowButton setTitle:ZFLocalizedString(@"PushAllowView_AllowBtnTitle", nil) forState:UIControlStateNormal];
        [_allowButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_allowButton addTarget:self action:@selector(allowButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allowButton;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleButton.layer.cornerRadius = 3;
        _cancleButton.layer.masksToBounds = YES;
        _cancleButton.backgroundColor = ZFCOLOR_WHITE;
        [_cancleButton setTitleColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
        _cancleButton.titleLabel.font = ZFFontBoldSize(16);
        [_cancleButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
//         [_cancleButton showCurrentViewBorder:1.0 color:ZFCOLOR(221, 221, 221, 1)];
        //[_cancleButton setTitle:ZFLocalizedString(@"PushAllowView_NotNow", nil) forState:UIControlStateNormal];
        
        // 取消标题加下划线
        NSString *title = ZFLocalizedString(@"PushAllowView_NotNow", nil);
        if (!title) {
            title = @"cancle";
        }
        
        NSMutableAttributedString *cancleTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [cancleTitle addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                            range:NSMakeRange(0, title.length)];
        
        [cancleTitle addAttribute:NSForegroundColorAttributeName
                            value:ZFCOLOR(153, 153, 153, 1)
                            range:NSMakeRange(0, title.length)];
        
        [_cancleButton setAttributedTitle:cancleTitle forState:UIControlStateNormal];
        
    }
    return _cancleButton;
}

@end
