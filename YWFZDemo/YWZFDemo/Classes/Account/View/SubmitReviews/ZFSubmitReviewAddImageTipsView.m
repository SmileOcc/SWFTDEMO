
//
//  ZFSubmitReviewAddImageTipsView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewAddImageTipsView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFSubmitReviewAddImageTipsView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *tipsLabel;
@end

@implementation ZFSubmitReviewAddImageTipsView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self);
    }];
}

#pragma mark - getter
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.text = ZFLocalizedString(@"ZFOrderReview_AddImageTips", nil);
    }
    return _tipsLabel;
}

@end
