//
//  ZFSearchResultErrorTitleView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultErrorTitleView.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

@interface ZFSearchResultErrorTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZFSearchResultErrorTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self).offset(12.0f);
        make.trailing.mas_equalTo(self).offset(-12.0f);
    }];
}

- (void)configWithGoodsNumber:(NSString *)goodsNumber keyword:(NSString *)keyword {
    NSString *titleString = [NSString stringWithFormat:ZFLocalizedString(@"search_result_matches_title", nil), goodsNumber, keyword];
    NSRange goodsNumberRange = [titleString rangeOfString:goodsNumber];
    NSRange keywordRange     = [titleString rangeOfString:keyword];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:titleString];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0x2d2d2d] range:goodsNumberRange];
    [attrString addAttribute:NSForegroundColorAttributeName value:ZFC0xFE5269() range:keywordRange];
    self.titleLabel.attributedText = attrString;
}

#pragma mark - getter/setter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x878787];
    }
    return _titleLabel;
}

@end
