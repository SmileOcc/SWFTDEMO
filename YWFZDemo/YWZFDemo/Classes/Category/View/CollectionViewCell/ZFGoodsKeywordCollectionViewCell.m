//
//  ZFGoodsKeywordCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/6/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsKeywordCollectionViewCell.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"

@interface ZFGoodsKeywordCollectionViewCell ()

@property (nonatomic, strong) UILabel *keywordLabel;

@end

@implementation ZFGoodsKeywordCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.keywordLabel];
    [self.keywordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.leading.mas_equalTo(self.contentView);
    }];
}

- (void)configDataWithKeyword:(NSString *)keyword isSelected:(BOOL)isSelected {
    self.keywordLabel.text = keyword;
    if (isSelected) {
        self.keywordLabel.textColor = ZFC0x2D2D2D();
        self.keywordLabel.backgroundColor = [UIColor whiteColor];
        self.keywordLabel.layer.borderWidth = 1.0;
        self.keywordLabel.layer.borderColor = ZFC0x2D2D2D().CGColor;
    } else {
        self.keywordLabel.textColor = [UIColor colorWithHex:0x666666];
        self.keywordLabel.backgroundColor = [UIColor colorWithHex:0xF7F7F7];
        self.keywordLabel.layer.borderWidth = 0.0;
    }
}

#pragma mark - getter/setter
- (UILabel *)keywordLabel {
    if (!_keywordLabel) {
        _keywordLabel = [[UILabel alloc] init];
        _keywordLabel.font = [UIFont systemFontOfSize:14.0];
        _keywordLabel.textColor = [UIColor colorWithHex:0x666666];
        _keywordLabel.backgroundColor = [UIColor colorWithHex:0xF7F7F7];
        _keywordLabel.textAlignment = NSTextAlignmentCenter;
        _keywordLabel.layer.cornerRadius = 2;
        _keywordLabel.layer.masksToBounds = YES;
    }
    return _keywordLabel;
}

@end
