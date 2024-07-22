//
//  ZFGoodsReviewFilterView.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoodsReviewFilterView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@implementation ZFGoodsReviewFilterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    [self.contentView addSubview:self.allButton];
    [self.contentView addSubview:self.latestButton];
    [self.contentView addSubview:self.pictureButton];
}

- (void)zfAutoLayoutView {
    
    [self.allButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.height.mas_equalTo(30);
    }];
    
    [self.latestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.allButton.mas_centerY);
        make.leading.mas_equalTo(self.allButton.mas_trailing).offset(8);
        make.height.mas_equalTo(30);
    }];
    
    [self.pictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.allButton.mas_centerY);
        make.leading.mas_equalTo(self.latestButton.mas_trailing).offset(8);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - action

- (void)actionEvent:(UIButton *)sender {
    NSInteger flag = sender.tag - 20000;
    if (_filterArray.count > flag) {
        ZFReviewFilterModel *currentModel = _filterArray[flag];
        if (currentModel.selectState) {
            return;
        }
    }
    
    for (int i=0; i<_filterArray.count; i++) {
        ZFReviewFilterModel *obj = _filterArray[i];
        obj.selectState = obj.type == flag ? YES : NO;
        UIButton *filterButton = [self viewWithTag:20000 + i];
        if (filterButton) {
            UIColor *titleColor = obj.selectState ? ZFC0x2D2D2D() : ColorHex_Alpha(0x666666, 1.0);
            UIColor *borderColor = obj.selectState ? ZFC0x2D2D2D() : [UIColor clearColor];
            UIColor *backColor = obj.selectState ? [UIColor clearColor] : ZFC0xF2F2F2();
            [filterButton setTitleColor:titleColor forState:UIControlStateNormal];
            [filterButton setBackgroundColor:backColor];
            filterButton.layer.borderColor = borderColor.CGColor;
            filterButton.layer.cornerRadius = 2;
            filterButton.layer.masksToBounds = YES;
        }
    }
    
    if (self.filterBlock) {
        self.filterBlock(_filterArray);
    }
}
#pragma mark - setter/getter

- (void)setFilterArray:(NSArray *)filterArray {
    if (ZFJudgeNSArray(filterArray)) {
        _filterArray = filterArray;
    } else {
        _filterArray = @[];
    }
    
    
    for (ZFReviewFilterModel *model in _filterArray) {
        NSInteger tag = 20000 + model.type;
        UIButton *eventButton = [self.contentView viewWithTag:tag];
        if (eventButton) {
            UIColor *titleColor = model.selectState ? ZFC0x2D2D2D() : ColorHex_Alpha(0x666666, 1.0);
            UIColor *borderColor = model.selectState ? ZFC0x2D2D2D() : [UIColor clearColor];
            UIColor *backColor = model.selectState ? [UIColor clearColor] : ZFC0xF2F2F2();
            [eventButton setTitleColor:titleColor forState:UIControlStateNormal];
            [eventButton setBackgroundColor:backColor];
            eventButton.layer.borderColor = borderColor.CGColor;
        }
    }
}

- (UIButton *)allButton {
    if (!_allButton) {
        _allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allButton setTitle:ZFLocalizedString(@"ReviewFilter_All", nil) forState:UIControlStateNormal];
        [_allButton setTitleColor:ColorHex_Alpha(0x2D2D2D, 1.0) forState:UIControlStateNormal];
        _allButton.titleLabel.font = ZFFontSystemSize(14);
        _allButton.layer.borderWidth = 1;
        _allButton.layer.borderColor = ColorHex_Alpha(0x2D2D2D, 1.0).CGColor;
        [_allButton setContentEdgeInsets:UIEdgeInsetsMake(7, 10, 7, 10)];
        _allButton.tag = 20000;
        [_allButton addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
        _allButton.layer.cornerRadius = 2;
        _allButton.layer.masksToBounds = YES;
    }
    return _allButton;
}

- (UIButton *)latestButton {
    if (!_latestButton) {
        _latestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_latestButton setTitle:ZFLocalizedString(@"ReviewFilter_Recent", nil) forState:UIControlStateNormal];
        [_latestButton setTitleColor:ColorHex_Alpha(0x666666, 1.0) forState:UIControlStateNormal];
        _latestButton.titleLabel.font = ZFFontSystemSize(14);
        _latestButton.backgroundColor = ZFC0xF2F2F2();
        _latestButton.layer.borderWidth = 1;
        [_latestButton setContentEdgeInsets:UIEdgeInsetsMake(7, 10, 7, 10)];
        _latestButton.tag = 20001;
        [_latestButton addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
        _latestButton.layer.cornerRadius = 2;
        _latestButton.layer.masksToBounds = YES;
    }
    return _latestButton;
}


- (UIButton *)pictureButton {
    if (!_pictureButton) {
        _pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pictureButton setTitle:ZFLocalizedString(@"ReviewFilter_Picture", nil) forState:UIControlStateNormal];
        [_pictureButton setTitleColor:ColorHex_Alpha(0x666666, 1.0) forState:UIControlStateNormal];
        _pictureButton.titleLabel.font = ZFFontSystemSize(14);
        _pictureButton.backgroundColor = ZFC0xF2F2F2();
        _pictureButton.layer.borderWidth = 1;
        [_pictureButton setContentEdgeInsets:UIEdgeInsetsMake(7, 10, 7, 10)];
        _pictureButton.tag = 20002;
        [_pictureButton addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
        _pictureButton.layer.cornerRadius = 2;
        _pictureButton.layer.masksToBounds = YES;
    }
    return _pictureButton;
}


@end


@implementation ZFReviewFilterModel

@end
