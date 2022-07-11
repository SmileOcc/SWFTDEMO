//
//  GoodsDetailsHeaderActivityStateView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsHeaderActivityStateView.h"

@implementation OSSVDetailsHeaderActivityStateView

- (instancetype)initWithFrame:(CGRect)frame showDirect:(STLActivityDirectStyle)direct{
    if (self = [super initWithFrame:frame]) {
                
        self.directStyle = direct;
        if (direct == STLActivityDirectStyleVertical) {
            [self addSubview:self.activityVerticalView];

            //闪购标签
            [self.activityVerticalView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self);
            }];
        } else {
            
            [self addSubview:self.activityNormalView];
            
            //闪购标签
            [self.activityNormalView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self);
            }];

        }
        
    }
    
    return self;
}

- (void)setFontSize:(NSInteger)fontSize {
    _fontSize = fontSize;
    if (_activityNormalView) {
        if (fontSize > 0) {
            _activityNormalView.fontSize = fontSize;
            _activityNormalView.discountLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        }
    }
    if (_activityVerticalView) {
        if (fontSize > 0) {
            _activityVerticalView.fontSize = fontSize;
            _activityVerticalView.discountLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        }
    }
}

- (void)setFlashImageSize:(NSInteger)flashImageSize {
    _flashImageSize = flashImageSize;
    if (_activityNormalView) {
        _activityNormalView.flashImageSize = flashImageSize;
    }
    if (_activityVerticalView) {
        _activityVerticalView.flashImageSize = flashImageSize;
    }
}

- (void)setSamllImageShow:(BOOL)samllImageShow {
    _samllImageShow = samllImageShow;
    if (_activityNormalView) {
        _activityNormalView.samllImageShow = samllImageShow;
    }
    if (_activityVerticalView) {
        _activityVerticalView.samllImageShow = samllImageShow;
    }
}

- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr;
{
    if (STLIsEmptyString(discountStr)) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    self.activityStyle = state;
    if (self.directStyle == STLActivityDirectStyleVertical) {
        if (!_activityVerticalView) {
            self.hidden = YES;
        } else {
            [self.activityVerticalView updateState:state discount:discountStr];
        }
    } else {
        if (!_activityNormalView) {
            self.hidden = YES;
        } else {
            [self.activityNormalView updateState:state discount:discountStr];
        }
    }
}


#pragma mark - Lazyload

- (GoodsDetailsHeaderActivityNormalView *)activityNormalView {
    if (!_activityNormalView) {
        _activityNormalView = [[GoodsDetailsHeaderActivityNormalView alloc] initWithFrame:CGRectZero];
    }
    return _activityNormalView;
}

- (GoodsDetailsHeaderActivityVeritcalView *)activityVerticalView {
    if (!_activityVerticalView) {
        _activityVerticalView = [[GoodsDetailsHeaderActivityVeritcalView alloc] initWithFrame:CGRectZero];
    }
    return _activityVerticalView;
}

@end


@implementation GoodsDetailsHeaderActivityNormalView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
//        [self addSubview:self.flashSaleImgView];
        [self addSubview:self.discountLabel];
        
        //闪购标签
//        [self.flashSaleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.mas_leading).offset(4);
//            make.centerY.mas_equalTo(self.mas_centerY);
//            make.height.width.mas_equalTo(@12);
//        }];
        
        [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.mas_top);
//            make.bottom.mas_equalTo(self.mas_bottom);
//            make.leading.mas_equalTo(self.flashSaleImgView.mas_trailing);
//            make.height.mas_equalTo(@16);
//            make.trailing.mas_equalTo(self.mas_trailing).offset(-4);
            make.edges.mas_equalTo(self);
//            make.top.leading.mas_equalTo(self);
//            make.size.equalTo(CGSizeMake(30, 14));
        }];
        
    }
    
    return self;
}

- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr;
{
    
//    self.flashSaleImgView.hidden = YES;

    NSString *contentStr = @"";
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//        contentStr = [NSString stringWithFormat:@"%@ %@%%",STLLocalizedString_(@"off", nil),discountStr];
        contentStr = [NSString stringWithFormat:@"-%@%%",discountStr];

    } else {
//        contentStr = [NSString stringWithFormat:@"%@%% %@ ",discountStr,STLLocalizedString_(@"off", nil)];
        contentStr = [NSString stringWithFormat:@"-%@%%",discountStr];
    }
    
    self.discountLabel.text = contentStr;
//    if (self.samllImageShow) {
//        self.flashSaleImgView.image = [UIImage imageNamed:@"black_flash_12"];
//    } else {
//        self.flashSaleImgView.image = [UIImage imageNamed:@"black_Flash_Icon"];
//    }
    
    if (APP_TYPE == 3) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        self.discountLabel.textColor = [OSSVThemesColors col_9F5123];
    } else {
        self.backgroundColor = [OSSVThemesColors col_0D0D0D];
        self.discountLabel.textColor = [OSSVThemesColors stlWhiteColor];
    }
    
    if (state == STLActivityStyleFlashSale) {
        if (APP_TYPE == 3) {
            self.discountLabel.textColor = [OSSVThemesColors stlBlackColor];
            self.backgroundColor = OSSVThemesColors.col_EEBA00;
        } else {
            self.backgroundColor = [OSSVThemesColors col_FFCF60];
            self.discountLabel.textColor = [OSSVThemesColors col_0D0D0D];
        }
        
    } else {
    }
    [self.discountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(14);
        make.width.equalTo(30);
    }];

}

- (UILabel *)discountLabel {
    if (!_discountLabel) {
        _discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discountLabel.backgroundColor = [OSSVThemesColors stlClearColor];
        _discountLabel.textColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            _discountLabel.font = [UIFont systemFontOfSize:10];
        } else {
            _discountLabel.font = [UIFont boldSystemFontOfSize:10];
        }
        _discountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _discountLabel;
}


- (UIImageView *)flashSaleImgView {
    if (!_flashSaleImgView) {
        _flashSaleImgView = [UIImageView new];
        _flashSaleImgView.image = [UIImage imageNamed:@"black_Flash_Icon"];
        _flashSaleImgView.hidden = YES;
    }
    return _flashSaleImgView;
}

@end



@implementation GoodsDetailsHeaderActivityVeritcalView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        

//        [self addSubview:self.flashSaleImgView];
        [self addSubview:self.discountLabel];
        
        //闪购标签
//        [self.flashSaleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.mas_top).offset(2);
//            make.centerX.mas_equalTo(self.mas_centerX);
//            make.height.width.equalTo(@16);
//        }];
        
        [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
//            make.top.mas_equalTo(self.mas_top).offset(@20);
//            make.leading.mas_equalTo(self.mas_leading).offset(1);
//            make.trailing.mas_equalTo(self.mas_trailing).offset(-1);
//            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-2);
//            make.width.mas_equalTo(@30);
//            make.leading.top.mas_equalTo(self);
//            make.width.equalTo(50);
//            make.height.equalTo(20);
        }];
    }
    
    return self;
}

- (void)updateState:(STLActivityStyle )state discount:(NSString *)discountStr {
    
//    self.flashSaleImgView.hidden = YES;
//    CGFloat maxWidth = 50;
//    NSString *discountString = [NSString stringWithFormat:@"%%%@ ",discountStr];
//
//    if (discountStr.length > 0) {
//        CGSize discountSize = [discountString textSizeWithFont:[UIFont boldSystemFontOfSize:self.fontSize > 0 ? self.fontSize : 12]
//                                   constrainedToSize:CGSizeMake(SCREEN_WIDTH - 32, MAXFLOAT)
//                                       lineBreakMode:NSLineBreakByWordWrapping];
//
//        CGSize offSize = [STLLocalizedString_(@"off", nil) textSizeWithFont:[UIFont boldSystemFontOfSize:self.fontSize > 0 ? self.fontSize : 12]
//                                   constrainedToSize:CGSizeMake(SCREEN_WIDTH - 32, MAXFLOAT)
//                                       lineBreakMode:NSLineBreakByWordWrapping];
//        maxWidth = discountSize.width > offSize.width ? discountSize.width : offSize.width;
//        maxWidth += 5;
//
//    }

    NSString *contentStr = @"";
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//        contentStr = [NSString stringWithFormat:@"%%%@\n%@",discountStr,STLLocalizedString_(@"off", nil)];
        contentStr = [NSString stringWithFormat:@"-%@%%",discountStr];

    } else {
//        contentStr = [NSString stringWithFormat:@"%@%%\n%@ ",discountStr,STLLocalizedString_(@"off", nil)];
        
        contentStr = [NSString stringWithFormat:@"-%@%%",discountStr];

    }
    
    self.discountLabel.text = contentStr;

    if (APP_TYPE == 3) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        self.discountLabel.textColor = [OSSVThemesColors col_9F5123];
    } else {
        self.backgroundColor = [OSSVThemesColors col_0D0D0D];
        self.discountLabel.textColor = [OSSVThemesColors stlWhiteColor];
    }
    
//    if (self.samllImageShow) {
//        self.flashSaleImgView.image = [UIImage imageNamed:@"black_flash_12"];
//    } else {
//        self.flashSaleImgView.image = [UIImage imageNamed:@"black_Flash_Icon"];
//    }
    if (state == STLActivityStyleFlashSale) {
        
//        self.flashSaleImgView.hidden = NO;

//        [self.flashSaleImgView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.width.equalTo(self.flashImageSize > 0 ? @(self.flashImageSize) : @16);
//        }];
        
        
        if (APP_TYPE == 3) {
            self.discountLabel.textColor = [OSSVThemesColors stlBlackColor];
            self.backgroundColor = OSSVThemesColors.col_EEBA00;
        } else {
            self.discountLabel.textColor = [OSSVThemesColors col_0D0D0D];
            self.backgroundColor = [OSSVThemesColors col_FFCF60];
        }
    } else {
        
//        [self.flashSaleImgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.width.equalTo(@16);
//        }];
//
//    [self.discountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.mas_top).offset(@2);
//        make.width.mas_equalTo(@(maxWidth));
//    }];
        
    }
    [self.discountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.mas_top).offset(self.flashImageSize > 0 ? @(self.flashImageSize+4) : @20);
        make.width.mas_equalTo(36);
        if (APP_TYPE == 3) {
            make.height.mas_equalTo(16);
        } else {
            make.height.mas_equalTo(18);
        }
    }];

    
}

- (UILabel *)discountLabel {
    if (!_discountLabel) {
        _discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discountLabel.backgroundColor = [OSSVThemesColors stlClearColor];
        _discountLabel.textColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            _discountLabel.font = [UIFont systemFontOfSize:10];

        } else {
            _discountLabel.font = [UIFont boldSystemFontOfSize:12];

        }
        _discountLabel.textAlignment = NSTextAlignmentCenter;
//        _discountLabel.numberOfLines = 2;
    }
    return _discountLabel;
}


- (UIImageView *)flashSaleImgView {
    if (!_flashSaleImgView) {
        _flashSaleImgView = [UIImageView new];
        _flashSaleImgView.image = [UIImage imageNamed:@"black_Flash_Icon"];
        _flashSaleImgView.hidden = YES;
    }
    return _flashSaleImgView;
}


@end
