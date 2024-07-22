//
//  ZFCartUnavailableViewAllFooterView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartUnavailableViewAllFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"

@interface ZFCartUnavailableViewAllFooterView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *containView;
@property (nonatomic, strong) UILabel           *tipsLabel;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@property (nonatomic, strong) UIView            *emptyWhiteView;
@end

@implementation ZFCartUnavailableViewAllFooterView

#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapGestureBock];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addTopLeftRightCorners];
}

- (void)addTopLeftRightCorners {
    [self.emptyWhiteView zfAddCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(8, 8)];
}

- (void)addTapGestureBock {
    @weakify(self);
    [self addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (self.cartUnavailableViewAllSelectCompletionHandler) {
            self.cartUnavailableViewAllSelectCompletionHandler(!self.isShowMore);
        }
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.emptyWhiteView];
    [self.contentView addSubview:self.containView];
    [self.containView addSubview:self.tipsLabel];
    [self.containView addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    [self.emptyWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 12, 0));
    }];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(-6);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView);
        make.top.bottom.mas_equalTo(self.containView);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tipsLabel.mas_trailing).offset(8);
        make.trailing.mas_equalTo(self.containView);
        make.centerY.mas_equalTo(self.tipsLabel.mas_centerY);
    }];
}

#pragma mark - setter
- (void)setIsShowMore:(BOOL)isShowMore {
    _isShowMore = isShowMore;
    
    self.tipsLabel.text = ZFLocalizedString(_isShowMore ? @"CartUnavailableFoldUpTips" : @"CartUnavailableViewMoreTips", nil) ;
    self.arrowImageView.image = [UIImage imageNamed: _isShowMore ? @"cart_unavailable_arrow_up" : @"cart_unavailable_arrow_down"];
}

#pragma mark - getter
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _containView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _tipsLabel.text = @"View More";
    }
    return _tipsLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"cart_unavailable_arrow_down"];
    }
    return _arrowImageView;
}

- (UIView *)emptyWhiteView {
    if (!_emptyWhiteView) {
        _emptyWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyWhiteView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyWhiteView;
}
@end
