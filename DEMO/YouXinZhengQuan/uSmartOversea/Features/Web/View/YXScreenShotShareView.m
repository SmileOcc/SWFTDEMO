//
//  YXScreenShotShareView.m
//  uSmartOversea
//
//  Created by mac on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXScreenShotShareView.h"
#import "YXShareSDKHelper.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

#define yxsize(x) ((x)*([UIScreen mainScreen].bounds.size.width/375.0))
@interface YXScreenShotShareView ()

@property (nonatomic, strong) UIImageView *shareImageView;
@property (nonatomic, strong) NSMutableArray *shareButtons;

@end

@implementation YXScreenShotShareView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
    
    self.backgroundColor = [UIColor blackColor];
    self.shareImageView.contentMode = UIViewContentModeScaleAspectFill;

    //图片
    [self addSubview:self.shareImageView];
    [self.shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.left.mas_equalTo(self.mas_left).offset(yxsize(45));
        make.top.mas_equalTo(self.mas_top).offset(30 + [YXConstant navBarPadding]);
        make.right.mas_equalTo(self.mas_right).offset(-yxsize(45));
        make.bottom.mas_equalTo(self.mas_bottom).offset(-180 - [YXConstant tabBarPadding]);
    }];
    
    //取消按钮(透明)
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-20);
        make.height.mas_equalTo(40);
    }];
    [cancelButton addTarget:self action:@selector(cancelButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self addSubview: scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(cancelButton.mas_top);
        make.top.equalTo(self.shareImageView.mas_bottom);
    }];
    
    //分享图标
    NSMutableArray *shareButtonArr = [NSMutableArray array];
    NSArray *imageArr = @[@"share-whats", @"share-fb", @"share-wechat", @"share-fb-messenger",@"share-line", @"savePic"];
    NSArray *titleArr = @[[YXShareSDKHelper titleForPlatforms:SSDKPlatformTypeWhatsApp],
                          [YXShareSDKHelper titleForPlatforms:SSDKPlatformTypeFacebook],
                          [YXShareSDKHelper titleForPlatforms:SSDKPlatformTypeWechat],
                          [YXShareSDKHelper titleForPlatforms:SSDKPlatformTypeFacebookMessenger],
                          [YXShareSDKHelper titleForPlatforms:SSDKPlatformTypeLine],
                          [YXLanguageUtility kLangWithKey:@"save_picture"]];
    for (int x = 0; x < imageArr.count; x ++) {
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton addTarget:self action:@selector(shareButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed: imageArr[x]] forState:UIControlStateNormal];
        [shareButton setTitle:titleArr[x] forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        shareButton.tag = x;
        shareButton.titleLabel.font = [UIFont systemFontOfSize:14];

        switch (x) {
            case 0: // Whatsapp
                if ([YXShareSDKHelper isClientIntalled:SSDKPlatformTypeWhatsApp]) {
                    [shareButtonArr addObject:shareButton];
                    [scrollView addSubview:shareButton];
                }
                break;
            case 1: // Facebook
                if ([YXShareSDKHelper isClientIntalled:SSDKPlatformTypeFacebook]) {
                    [shareButtonArr addObject:shareButton];
                    [scrollView addSubview:shareButton];
                }
                break;
            case 2: // Wechat
                if ([YXShareSDKHelper isClientIntalled:SSDKPlatformTypeWechat]) {
                    [shareButtonArr addObject:shareButton];
                    [scrollView addSubview:shareButton];
                }
                break;
            case 3: // facebook messenger
                if ([YXShareSDKHelper isClientIntalled:SSDKPlatformTypeFacebookMessenger]) {
                    [shareButtonArr addObject:shareButton];
                    [scrollView addSubview:shareButton];
                }
                break;
            case 4: // Line
                if ([YXShareSDKHelper isClientIntalled:SSDKPlatformTypeLine]) {
                    [shareButtonArr addObject:shareButton];
                    [scrollView addSubview:shareButton];
                }
                break;
            default: // 保存图片
                [shareButtonArr addObject:shareButton];
                [scrollView addSubview:shareButton];
                break;
        }
    }

    for (int i=0; i<shareButtonArr.count; i++) {
        UIButton *btn = shareButtonArr[i];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scrollView).offset(20+80*i);
            make.top.equalTo(scrollView).offset(15);
            make.height.width.mas_equalTo(80);
        }];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-
                                                 btn.imageView.frame.size.width, 0.0,0.0)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.imageView.frame.size.width/2, 0, 0, -
                                                 btn.titleLabel.bounds.size.width)];
    }
    [scrollView setContentSize:CGSizeMake(40+80*shareButtonArr.count, scrollView.frame.size.height)];
    
}

- (UIImageView *)shareImageView{
    
    if (!_shareImageView) {
        _shareImageView = [[UIImageView alloc] init];
    }
    return _shareImageView;
}

- (void)shareButtonEvent:(UIButton *)button{
    SSDKPlatformType type;
    switch (button.tag) {
        case 0: // Whatsapp
            type = SSDKPlatformTypeWhatsApp;
            break;
        case 1: // facebook
            type = SSDKPlatformTypeFacebook;
            break;
        case 2: // Wechat
            type = SSDKPlatformTypeWechat;
            break;
        case 3: // facebook messenger
            type = SSDKPlatformTypeFacebookMessenger;
            break;
        case 4: // Line
            type = SSDKPlatformTypeLine;
            break;
        case 5: //保存图片
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            return;
        default:
            type = SSDKPlatformTypeUnknown;
            break;
    }
    UIImage *shareImage = [self normalSnapShotImage];
    [[YXShareSDKHelper shareInstance] share:type text:nil images:@[shareImage] url:nil title:nil type:SSDKContentTypeImage withCallback:^(BOOL success, NSDictionary *userInfo, SSDKPlatformType platformType) {
        if (self.shareResultBlock) {
            self.shareResultBlock(success);
        }
        [self removeFromSuperview];
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"user_saveFailed"]];
    } else {
        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"user_saveSucceed"]];
    }
}

- (UIImage *)normalSnapShotImage{
    
    UIGraphicsBeginImageContextWithOptions(self.shareImageView.frame.size, NO, [UIScreen mainScreen].scale);
    [self.shareImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
    
}

- (void)cancelButtonEvent{
    if (self.shareResultBlock) {
        self.shareResultBlock(NO);
    }
    [self removeFromSuperview];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _shareImageView.image = image;
}


@end
