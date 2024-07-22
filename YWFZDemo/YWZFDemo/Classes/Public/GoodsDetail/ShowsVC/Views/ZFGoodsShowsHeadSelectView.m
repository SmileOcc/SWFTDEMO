//
//  ZFGoodsShowsHeadSelectView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsHeadSelectView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsShowsHeadSelectView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIButton              *showsButton;
@property (nonatomic, strong) UIButton              *relatedItemButton;
@property (nonatomic, strong) UIView                *selectLineView;
@property (nonatomic, strong) UIView                *topLineView;
@property (nonatomic, strong) UIView                *underLineView;
@end

@implementation ZFGoodsShowsHeadSelectView
#pragma mark - Life Cycle
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
    [self addSubview:self.showsButton];
    [self addSubview:self.relatedItemButton];
    [self addSubview:self.selectLineView];
    [self addSubview:self.topLineView];
    [self addSubview:self.underLineView];
    self.topLineView.hidden = YES;
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
    
    [self.showsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth / 2.0);
    }];
    
    [self.relatedItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.leading.mas_equalTo(self.showsButton.mas_trailing);
        make.width.mas_equalTo(KScreenWidth / 2.0);
    }];
    
    [self.selectLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(52);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(2.5);
        make.centerX.mas_equalTo(self.showsButton.mas_centerX);
    }];
    
    [self.underLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
}

#pragma mark - action methods

- (void)headSelectAction:(UIButton *)sender {
    if (self.selectCompletionHandler) {
        self.currentType = sender.tag;
        self.selectCompletionHandler(sender.tag);
    }
}

#pragma mark - setter
- (void)setCurrentType:(ZFGoodsShowsHeadSelectType)currentType {
    self.relatedItemButton.selected = NO;
    self.showsButton.selected = NO;
    _currentType = currentType;
    
    UIButton *selectButton;
    //根据选中，改变按钮样式， 以及选中下划线位置。
    switch (_currentType) {
        case ZFGoodsShowsHeadSelectType_Shows:
        {
            self.showsButton.selected = YES;
            selectButton = self.showsButton;
        }
            break;
            
        case ZFGoodsShowsHeadSelectType_RelatedItems:
        {
            self.relatedItemButton.selected = YES;
            selectButton = self.relatedItemButton;
        }
            break;
    }
    [self.selectLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(52);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(2.5);
        make.centerX.mas_equalTo(selectButton.mas_centerX);
    }];
}

#pragma mark - getter
- (UIButton *)showsButton {
    if (!_showsButton) {
        _showsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showsButton setTitle:ZFLocalizedString(@"goodsShows_header_showItems",nil) forState:UIControlStateNormal];
        [_showsButton setTitle:ZFLocalizedString(@"goodsShows_header_showItems",nil) forState:UIControlStateSelected];
        [_showsButton setTitleColor:ZFCOLOR(51, 51, 51, 1.f) forState:UIControlStateSelected];
        [_showsButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        _showsButton.titleLabel.font = ZFFontSystemSize(16);
        _showsButton.tag = ZFGoodsShowsHeadSelectType_Shows;
        _showsButton.selected = YES;
        [_showsButton addTarget:self action:@selector(headSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showsButton;
}

- (UIButton *)relatedItemButton {
    if (!_relatedItemButton) {
        _relatedItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_relatedItemButton setTitle:ZFLocalizedString(@"goodsShows_header_relatedItems",nil) forState:UIControlStateNormal];
        [_relatedItemButton setTitle:ZFLocalizedString(@"goodsShows_header_relatedItems",nil) forState:UIControlStateSelected];
        [_relatedItemButton setTitleColor:ColorHex_Alpha(0x2D2D2D, 1.0f) forState:UIControlStateSelected];
        [_relatedItemButton setTitleColor:ColorHex_Alpha(0x999999, 1.0f) forState:UIControlStateNormal];
        _relatedItemButton.titleLabel.font = ZFFontSystemSize(14);
        _relatedItemButton.tag = ZFGoodsShowsHeadSelectType_RelatedItems;
        [_relatedItemButton addTarget:self action:@selector(headSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _relatedItemButton;
}

- (UIView *)selectLineView {
    if (!_selectLineView) {
        _selectLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectLineView.backgroundColor = ZFCOLOR(45, 45, 45, 1.f);
    }
    return _selectLineView;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _topLineView;
}

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _underLineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _underLineView;
}

@end
