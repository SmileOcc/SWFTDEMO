//
//  ZFOfflineOrderMethodCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOfflineOrderMethodCCell.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "ZFSystemPhototHelper.h"
#import <Masonry/Masonry.h>

@interface ZFOfflineOrderMethodCCell ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *checkOrderButton;
@property (nonatomic, strong) UIButton *shoppingButton;

@end

@implementation ZFOfflineOrderMethodCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(KScreenWidth);
        }];
        
        [self addSubview:self.saveButton];
        [self addSubview:self.checkOrderButton];
        [self addSubview:self.shoppingButton];
        
        [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(0);
            make.leading.mas_equalTo(self).mas_offset(16);
            make.trailing.mas_equalTo(self).mas_offset(-16);
            make.height.mas_offset(44);
        }];
        
        [self.checkOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.saveButton.mas_bottom).mas_offset(16);
            make.leading.mas_equalTo(self.saveButton);
            make.trailing.mas_equalTo(self.shoppingButton.mas_leading).mas_offset(-10);
            make.height.mas_offset(36);
        }];
        
        [self.shoppingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.checkOrderButton);
            make.trailing.mas_equalTo(self.saveButton);
            make.leading.mas_equalTo(self.checkOrderButton.mas_trailing).mas_offset(10);
            make.height.mas_equalTo(self.checkOrderButton);
            make.width.mas_equalTo(self.checkOrderButton);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-10);
        }];
    }
    return self;
}

#pragma mark - target

- (void)saveButtonClick
{
    if ([ZFSystemPhototHelper isCanUsePhotos]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(KScreenWidth, KScreenHeight), NO, 0.0);
        [WINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (screenShotImage) {
            UIImageWriteToSavedPhotosAlbum(screenShotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }
    } else {
        ShowToastToViewWithText(self.superview, ZFLocalizedString(@"AccoundHeaderView_Settings_Photos",nil));
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    YWLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        ShowToastToViewWithText(self.superview, ZFLocalizedString(@"Success", nil));
    } else {
        YWLog(@"%@", error.description);
    }
}

//查看支付凭证点击事件
- (void)checkButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOfflineOrderMethodCCellDidClickCheckOrderButton)]) {
        [self.delegate ZFOfflineOrderMethodCCellDidClickCheckOrderButton];
    }
}

//继续购物点击事件
- (void)shoppingButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOfflineOrderMethodCCellDidClickCheckCode)]) {
        [self.delegate ZFOfflineOrderMethodCCellDidClickCheckCode];
    }
}

#pragma mark - Property Method

-(void)setModel:(ZFOrderPayResultModel *)model
{
    _model = model;
    
    if ([_model isBoletoPayment]) {
        [_shoppingButton setTitle:ZFLocalizedString(@"Imprima o boleto", nil) forState:UIControlStateNormal];
    } else if ([_model isOXXOPayment]) {
        [_shoppingButton setTitle:ZFLocalizedString(@"PayOffline_PrintOXXOInfo", nil) forState:UIControlStateNormal];
    }
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = ZFC0x2D2D2D();
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"PayOffline_ScreenShot", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _saveButton;
}

- (UIButton *)checkOrderButton {
    if (!_checkOrderButton) {
        _checkOrderButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.borderColor = ZFC0x2D2D2D().CGColor;
            button.layer.borderWidth = 1;
            [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"orderListButton", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(checkButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _checkOrderButton;
}

- (UIButton *)shoppingButton {
    if (!_shoppingButton) {
        _shoppingButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.borderColor = ZFC0x2D2D2D().CGColor;
            button.layer.borderWidth = 1;
            [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"Imprima o boleto", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(shoppingButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _shoppingButton;
}


@end
