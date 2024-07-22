//
//  ZFOrderFailureViewController.m
//  ZZZZZ
//
//  Created by DBP on 16/12/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderFailureViewController.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFOrderFailureViewController ()

@end

@implementation ZFOrderFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    // 统计数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self eventLog];
    });
}

#pragma mark - UI
- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    YYAnimatedImageView *img = [[YYAnimatedImageView alloc] init];
    img.image = [UIImage imageNamed:@"payFailure"];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(160 *ScreenHeight_SCALE);
        
        make.width.equalTo(@140);
        make.height.equalTo(@90);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.font = [UIFont systemFontOfSize:17.0];
    tipLab.textColor = ZFCOLOR(15, 15, 15, 1.0);
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.text = ZFLocalizedString(@"OrderFailure_VC_Tip",nil);
    [self.view addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(img.mas_bottom).offset(16);
        make.leading.offset(12);
        make.trailing.offset(-12);
    }];
    
    UIButton *accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    accountBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [accountBtn setTitle:ZFLocalizedString(@"OrderFailure_VC_Account_Button",nil) forState:UIControlStateNormal];
    [accountBtn setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
    accountBtn.backgroundColor = ZFC0x2D2D2D();
    accountBtn.layer.cornerRadius = 4;
    accountBtn.clipsToBounds = YES;
    accountBtn.tag = 1234;
    
    [accountBtn addTarget:self action:@selector(jumpToAccoutOrHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accountBtn];
    [accountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLab.mas_bottom).offset(60 *ScreenHeight_SCALE);
        make.leading.offset(64 *ScreenWidth_SCALE);
        make.trailing.offset(-64 *ScreenWidth_SCALE);
        make.height.equalTo(@40);
    }];
    
}

- (void)jumpToAccoutOrHome:(UIButton *)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.orderFailureBlock) {
        self.orderFailureBlock();
    }
}

#pragma mark - 统计
- (void)eventLog
{
    // 谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:@"Payment Failure"];
}

@end

