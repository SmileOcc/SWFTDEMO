//
//  ZFShoppingCarTopTipView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFShoppingCarTopTipView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "SystemConfigUtils.h"
#import "ZFThemeManager.h"
#import "UIImage+ZFExtended.h"

static CGFloat kShoppingCarTopSpace = 7.0;

@interface ZFShoppingCarTopTipView() <ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *suonaImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIImageView           *arrowImageView;
@end

@implementation ZFShoppingCarTopTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapTopTipViewAction];
    }
    return self;
}

- (void)addTapTopTipViewAction {
    @weakify(self);
    [self addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (self.tapTopTipViewBlock && !self.arrowImageView.hidden) {
            self.tapTopTipViewBlock();
        }
    }];
}

- (void)cartTipText:(NSString *)cartTipText
          showArrow:(BOOL)showArrow
            bgColor:(UIColor *)bgColor
{
    self.titleLabel.text = ZFToString(cartTipText);
//    self.titleLabel.textAlignment = showArrow ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    self.arrowImageView.hidden = !showArrow;
    
    if ([bgColor isKindOfClass:[UIColor class]]) {
        self.backgroundColor = bgColor;
    }
}

- (CGFloat)emptViewMinHeight {
    return kShoppingCarTopSpace + kShoppingCarTopSpace;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self addSubview:self.suonaImageView];
    [self addSubview:self.arrowImageView];
    [self addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.suonaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-15);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(kShoppingCarTopSpace);
        make.leading.mas_equalTo(self.suonaImageView.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-5);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kShoppingCarTopSpace);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0xFFFFFF();
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = KScreenWidth - 80;
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _arrowImageView.image = [[UIImage imageNamed:@"car_topTip_arrow"] imageWithColor:ZFC0xFFFFFF()];
        _arrowImageView.userInteractionEnabled = YES;
        _arrowImageView.hidden = YES;
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (YYAnimatedImageView *)suonaImageView {
    if (!_suonaImageView) {
        _suonaImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
//        _suonaImageView.image = [YYImage imageNamed:@"car_suona_topTip"];
        _suonaImageView.image = [UIImage imageNamed:@"car_suona_topTip"];
        _suonaImageView.userInteractionEnabled = YES;
        if ([SystemConfigUtils isRightToLeftLanguage]) {
            _suonaImageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _suonaImageView;
}

@end
