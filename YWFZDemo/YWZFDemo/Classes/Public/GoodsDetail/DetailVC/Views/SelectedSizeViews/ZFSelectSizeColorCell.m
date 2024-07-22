
//
//  ZFSelectSizeColorCell.m
//  ZZZZZ
//
//  Created by YW on 2017/12/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSelectSizeColorCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"

@interface ZFSelectSizeColorCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UIImageView           *colorView;
@property (nonatomic, assign) CGSize                colorSize;
@end

@implementation ZFSelectSizeColorCell

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum])
        return nil;
    return ColorHex_Alpha(hexNum, 1.0);
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.colorView];
    [self.contentView addSubview:self.iconImageView];
}

- (void)zfAutoLayoutView {
    
    self.colorSize = CGSizeMake(30, 30);
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.colorSize);
    }];
        
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(self.colorSize.width + 6, self.colorSize.height + 6));
    }];
}

- (void)updateColorSize:(CGSize)size itmesModel:(ZFSizeSelectItemsModel *)model {
    
    if (!CGSizeEqualToSize(size, self.colorSize)) {
        self.colorSize = size;
    }
    [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(self.colorSize);
    }];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(self.colorSize.width + 6, self.colorSize.height + 6));
    }];
    
    self.model = model;
}

#pragma mark - setter
- (void)setModel:(ZFSizeSelectItemsModel *)model {
    _model = model;
    
    if ([_model.color hasPrefix:@"#"]) {
        NSString *colorStr = [_model.color componentsSeparatedByString:@"#"][1];
        self.colorView.backgroundColor = [self colorWithHexString:colorStr];
    } else {
        self.colorView.backgroundColor = ZFCOLOR_WHITE;
    }
    
    if (!ZFIsEmptyString(_model.color_img)) {
        [self.colorView yy_setImageWithURL:[NSURL URLWithString:_model.color_img]
                               placeholder:nil
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    } else {
        if (self.colorView.image) {
            self.colorView.image = nil;
        }
    }
    
    if (_model.is_click) {
        if (_model.isSelect) {
            self.iconImageView.image = [[UIImage imageNamed:@"select_color_on"] imageWithColor:ZFC0x2D2D2D()];
        } else {
            self.iconImageView.image = [UIImage imageNamed:@"select_color_normal"];
        }
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"select_color_unc"];
    }
}

#pragma mark - getter
- (UIImageView *)colorView {
    if (!_colorView) {
        _colorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _colorView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _colorView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

@end
