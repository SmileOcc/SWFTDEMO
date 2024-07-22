//
//  ZFSizeSelectSizeTipsTextCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSizeSelectSizeTipsTextCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "GoodsDetialSizeModel.h"

@interface ZFSizeSelectSizeTipsTextCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UIView                            *middleLineView;
@property (nonatomic, strong) UILabel                           *valueLabel;
@property (nonatomic, strong) UIView                            *rightLineView;
@end

@implementation ZFSizeSelectSizeTipsTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.middleLineView];
    [self.contentView addSubview:self.valueLabel];
    [self.contentView addSubview:self.rightLineView];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(28);
    }];
    
    [self.middleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.middleLineView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(28);
    }];
    
    [self.rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(1, 56));
    }];
}

#pragma mark - setter

- (void)setTipsTextModel:(ZFSizeTipsTextModel *)tipsTextModel {
    _tipsTextModel = tipsTextModel;
    self.titleLabel.text = ZFToString(tipsTextModel.title);
    self.valueLabel.text = ZFToString(tipsTextModel.value);
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = ZFCOLOR(248, 248, 248, 1);
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)middleLineView {
    if (!_middleLineView) {
        _middleLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _middleLineView.backgroundColor = ZFCOLOR(236, 236, 236, 1);
    }
    return _middleLineView;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.backgroundColor = ZFCOLOR(248, 248, 248, 1);
        _valueLabel.font = [UIFont systemFontOfSize:12];
        _valueLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _valueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLabel;
}

- (UIView *)rightLineView {
    if (!_rightLineView) {
        _rightLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightLineView.backgroundColor = ZFCOLOR(236, 236, 236, 1);
    }
    return _rightLineView;
}


@end
