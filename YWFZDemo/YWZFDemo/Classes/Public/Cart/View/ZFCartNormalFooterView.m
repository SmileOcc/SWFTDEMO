//
//  ZFCartNormalFooterView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartNormalFooterView.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "Masonry.h"

@interface ZFCartNormalFooterView ()
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation ZFCartNormalFooterView

#pragma mark - init methods

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self addTopLeftRightCorners];
}

- (void)addTopLeftRightCorners {
    [self.emptyView zfAddCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.emptyView];
}

- (void)zfAutoLayoutView {
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(12);
    }];
}

- (void)setShowCornersView:(BOOL)showCornersView {
    _showCornersView = showCornersView;
    self.emptyView.hidden = !showCornersView;
}

#pragma mark - getter

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyView;
}

@end
