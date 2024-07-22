

//
//  ZFCommunitySearchNoResultView.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchNoResultView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFCommunitySearchNoResultView () <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *noResultTipsLabel;
@end

@implementation ZFCommunitySearchNoResultView
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
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self addSubview:self.noResultTipsLabel];
}

- (void)zfAutoLayoutView {
    [self.noResultTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.center.mas_equalTo(self);
    }];
}

#pragma mark - getter
- (UILabel *)noResultTipsLabel {
    if (!_noResultTipsLabel) {
        _noResultTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noResultTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noResultTipsLabel.numberOfLines = 0;
        _noResultTipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _noResultTipsLabel.font = [UIFont systemFontOfSize:14];
        _noResultTipsLabel.text = ZFLocalizedString(@"CommunitySearchNoResultTips", nil);
    }
    return _noResultTipsLabel;
}
@end
