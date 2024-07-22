//
//  ZFCommunityAccountSelectView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountSelectView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityAccountSelectView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIButton              *showButton;
@property (nonatomic, strong) UIButton              *favesButton;
@property (nonatomic, strong) UIView                *selectLineView;
@property (nonatomic, strong) UIView                *topLineView;
@property (nonatomic, strong) UIView                *underLineView;
@end

@implementation ZFCommunityAccountSelectView
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
+ (NSInteger)arCurrentType:(ZFCommunityAccountSelectType)type {
    if (ZFCommunityAccountSelectTypeAllCount > type) {
        return [SystemConfigUtils isRightToLeftShow] ? ZFCommunityAccountSelectTypeAllCount - type - 1 : type;
    }
    return 0;
}
- (void)communityShowsAction:(UIButton *)sender {
    if (self.communityAccountSelectCompletionHandler && !sender.isSelected) {
        self.communityAccountSelectCompletionHandler(ZFCommunityAccountSelectTypeShow);
        self.currentType = ZFCommunityAccountSelectTypeShow;
    }
}

- (void)communityFavesAction:(UIButton *)sender {
    if (self.communityAccountSelectCompletionHandler && !sender.isSelected) {
        self.communityAccountSelectCompletionHandler(ZFCommunityAccountSelectTypeFaves);
        self.currentType = ZFCommunityAccountSelectTypeFaves;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.showButton];
    [self addSubview:self.favesButton];
    [self addSubview:self.selectLineView];
    [self addSubview:self.topLineView];
    [self addSubview:self.underLineView];
    self.topLineView.hidden = YES;
    self.underLineView.hidden = YES;
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
    
    [self.showButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth / 2.0);
    }];
    
    [self.favesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.leading.mas_equalTo(self.showButton.mas_trailing);
        make.width.mas_equalTo(KScreenWidth / 2.0);
    }];
    
    [self.selectLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(52);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(2.5);
        make.centerX.mas_equalTo(self.showButton.mas_centerX);
    }];
    
    [self.underLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
}

#pragma mark - setter
- (void)setCurrentType:(ZFCommunityAccountSelectType)currentType {
    self.favesButton.selected = NO;
    self.showButton.selected = NO;
    _currentType = currentType;
    UIButton *selectButton;
    //根据选中，改变按钮样式， 以及选中下划线位置。
    switch (_currentType) {
        case ZFCommunityAccountSelectTypeShow:
            self.showButton.selected = YES;
            selectButton = self.showButton;
            break;
            
        case ZFCommunityAccountSelectTypeFaves:
            self.favesButton.selected = YES;
            selectButton = self.favesButton;
            break;
        case ZFCommunityAccountSelectTypeAllCount:
            //去黄字专用
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
- (UIButton *)showButton {
    if (!_showButton) {
        _showButton = [UIButton buttonWithType:UIButtonTypeCustom];

//        [_showButton setTitle:ZFLocalizedString(@"MyStylePage_SubVC_Shows",nil) forState:UIControlStateNormal];
//        [_showButton setTitle:ZFLocalizedString(@"MyStylePage_SubVC_Shows",nil) forState:UIControlStateSelected];
//        [_showButton setTitleColor:ColorHex_Alpha(0x2D2D2D, 1.0f) forState:UIControlStateSelected];
//        [_showButton setTitleColor:ColorHex_Alpha(0x999999, 1.0f) forState:UIControlStateNormal];
//        _showButton.titleLabel.font = ZFFontSystemSize(14);

        [_showButton setTitle:ZFLocalizedString(@"Community_AccountShowsBtn",nil) forState:UIControlStateNormal];
        [_showButton setTitle:ZFLocalizedString(@"Community_AccountShowsBtn",nil) forState:UIControlStateSelected];
        [_showButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateSelected];
        [_showButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _showButton.titleLabel.font = ZFFontBoldSize(14);

        _showButton.tag = ZFCommunityAccountSelectTypeShow;
        _showButton.selected = YES;
        [_showButton addTarget:self action:@selector(communityShowsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showButton;
}

- (UIButton *)favesButton {
    if (!_favesButton) {
        _favesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favesButton setTitle:ZFLocalizedString(@"Community_Tab_Title_Faves",nil) forState:UIControlStateNormal];
        [_favesButton setTitle:ZFLocalizedString(@"Community_Tab_Title_Faves",nil) forState:UIControlStateSelected];
        [_favesButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateSelected];
        [_favesButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _favesButton.titleLabel.font = ZFFontBoldSize(14);
        _favesButton.tag = ZFCommunityAccountSelectTypeFaves;
        [_favesButton addTarget:self action:@selector(communityFavesAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _favesButton;
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
