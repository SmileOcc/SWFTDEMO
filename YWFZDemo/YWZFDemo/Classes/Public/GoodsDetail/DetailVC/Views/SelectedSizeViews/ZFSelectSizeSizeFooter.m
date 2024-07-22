//
//  ZFSelectSizeSizeFooter.m
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSelectSizeSizeFooter.h"
#import "ZFInitViewProtocol.h"
#import "UILabel+HTML.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectSizeSizeFooter() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *tipsLabel;
@property (nonatomic, strong) UIView            *bgView;
@end

@implementation ZFSelectSizeSizeFooter
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

+ (CGFloat)tipsCanCalculateWidth {
    return KScreenWidth - 2 * kSizeSelectLeftSpace - 2 * kSizeSelectSizeSpace;
}

+ (CGFloat)tipsTopBottomSpace {
    return 12 + 2 * kSizeSelectSizeSpace;
}
#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.bgView];
    [self addSubview:self.tipsLabel];    
}

- (void)zfAutoLayoutView {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(kSizeSelectLeftSpace);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-kSizeSelectLeftSpace);
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];

    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(kSizeSelectSizeSpace);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-kSizeSelectSizeSpace);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
}

- (void)updateLayout {
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(0);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
    }];
    
    [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(kSizeSelectSizeSpace);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-kSizeSelectSizeSpace);
    }];
}

#pragma mark - setter
- (void)setTipsInfo:(NSString *)tipsInfo {
    _tipsInfo = tipsInfo;

    CGFloat space = [ZFSelectSizeSizeFooter tipsTopBottomSpace];
    NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;//连字符
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    if (self.height > (kSizeSelectTempSpace + space)) {
        paragraphStyle.lineSpacing = 4;//连字符
    }
    NSDictionary *attrDict =@{NSFontAttributeName:ZFFontSystemSize(12),
                              NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attrStr =[[NSAttributedString alloc] initWithString:ZFToString(tipsInfo) attributes:attrDict];
    
    self.tipsLabel.attributedText = attrStr;
}

#pragma mark - getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = ColorHex_Alpha(0xCCCCCC, 0.05);
//        _bgView.layer.borderColor = ColorHex_Alpha(0xCCCCCC, 0.2).CGColor;
//        _bgView.layer.borderWidth = 1.0;
    }
    return _bgView;
}
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _tipsLabel.backgroundColor = [UIColor whiteColor];
        _tipsLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _tipsLabel.font = ZFFontSystemSize(12);
        _tipsLabel.numberOfLines = 2;
    }
    return _tipsLabel;
}

@end
