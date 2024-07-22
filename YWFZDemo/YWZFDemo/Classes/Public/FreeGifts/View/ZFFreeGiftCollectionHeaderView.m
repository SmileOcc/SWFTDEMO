//
//  ZFFreeGiftCollectionHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFreeGiftCollectionHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

#ifdef __IPHONE_11_0
@implementation ZFFreeGiftCustomLayer
- (CGFloat) zPosition {
    return 0;
}
@end
#endif

@interface ZFFreeGiftCollectionHeaderView() <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *subTitleLabel;

@end

@implementation ZFFreeGiftCollectionHeaderView
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
    [self addSubview:self.titleLabel];
    [self addSubview:self.subTitleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.mas_top).offset(18);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFFreeGiftListModel *)model {
    _model = model;
    self.titleLabel.text = ZFToString(model.title);
    self.subTitleLabel.text = ZFToString(model.sub_title);
}

#pragma mark - getter
#ifdef __IPHONE_11_0
+ (Class)layerClass {
    return [ZFFreeGiftCustomLayer class];
}
#endif

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.numberOfLines = 2;
    }
    return _subTitleLabel;
}

@end
