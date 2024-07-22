//
//  ZFOutfitRefineContainerView.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOutfitRefineContainerView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#import "UIView+ZFViewCategorySet.h"

static NSString *const khideOutfitRefineAnimationIdentifier = @"khideOutfitRefineAnimationIdentifier";
static NSString *const kshowOutfitRefineAnimationIdentifier = @"kshowOutfitRefineAnimationIdentifier";

@interface ZFOutfitRefineContainerView ()<CAAnimationDelegate,ZFInitViewProtocol>
@property (nonatomic, strong) UIView                        *maskView;
@property (nonatomic, strong) ZFOutfitSelectedRefineView    *refineInfoView;
@property (nonatomic, strong) UIView                        *bottomView;
@property (nonatomic, strong) CABasicAnimation              *showRefineInfoViewAnimation;
@property (nonatomic, strong) CABasicAnimation              *hideRefineInfoViewAnimation;
@end

@implementation ZFOutfitRefineContainerView

#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [self addSubview:self.maskView];
    [self addSubview:self.bottomView];
    [self addSubview:self.refineInfoView];
}

- (void)zfAutoLayoutView {
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.width.mas_equalTo(75);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(IPHONE_X_5_15 ? 34 : 0);
    }];
    
    [self.refineInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.leading.mas_equalTo(self.mas_leading).offset(75);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - Setter
-(void)setModel:(CategoryRefineSectionModel *)model {
    _model = model;
    self.refineInfoView.categroyRefineModel = model;
}

#pragma mark - Public Methods
- (void)showViewAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    self.refineInfoView.hidden = NO;
    
    [self.refineInfoView.layer addAnimation:self.showRefineInfoViewAnimation forKey:kshowOutfitRefineAnimationIdentifier];
    
}

- (void)hideViewAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    [self.refineInfoView.layer addAnimation:self.hideRefineInfoViewAnimation forKey:khideOutfitRefineAnimationIdentifier];
}

- (void)clearData {
    [self.refineInfoView clearRequestParmaters];
}


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.hideBlock) {
        self.refineInfoView.hidden = YES;
        self.hideBlock();
    }
}

#pragma mark - Gesture Handle
- (void)hideRefineView {
    [self hideViewAnimation:YES];
}

#pragma mark - Getter
-(UIView *)maskView {
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRefineView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (ZFOutfitSelectedRefineView *)refineInfoView {
    if (!_refineInfoView) {
        _refineInfoView = [[ZFOutfitSelectedRefineView alloc] init];
        _refineInfoView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _refineInfoView.hidden = NO;
        @weakify(self)
        _refineInfoView.applyBlock = ^(NSDictionary *parms) {
            @strongify(self);
            if (self.applyBlock) {
                self.applyBlock(parms);
            }
        };
        
        _refineInfoView.selectBlock = ^(BOOL select) {
            @strongify(self);
            if (self.selectBlock) {
                self.selectBlock(select);
            }
        };
        
        _refineInfoView.closeBlock = ^(BOOL close) {
            @strongify(self);
            if (self.closeBlock) {
                self.closeBlock(close);
            }
        };
    }
    return _refineInfoView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _bottomView;
}
- (CABasicAnimation *)showRefineInfoViewAnimation {
    if (!_showRefineInfoViewAnimation) {
        _showRefineInfoViewAnimation = [CABasicAnimation animation];
        _showRefineInfoViewAnimation.keyPath = @"position.x";
        _showRefineInfoViewAnimation.fromValue = [SystemConfigUtils isRightToLeftShow] ? @(-KScreenWidth * 0.5) : @(KScreenWidth * 1.5);
        _showRefineInfoViewAnimation.toValue = [SystemConfigUtils isRightToLeftShow] ?  @((KScreenWidth-75) / 2) : @((KScreenWidth-75) / 2 + 75);
        _showRefineInfoViewAnimation.duration = 0.25f;
        _showRefineInfoViewAnimation.removedOnCompletion = NO;
        _showRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
    }
    return _showRefineInfoViewAnimation;
}

- (CABasicAnimation *)hideRefineInfoViewAnimation {
    if (!_hideRefineInfoViewAnimation) {
        _hideRefineInfoViewAnimation = [CABasicAnimation animation];
        _hideRefineInfoViewAnimation.keyPath = @"position.x";
        _hideRefineInfoViewAnimation.fromValue = [SystemConfigUtils isRightToLeftShow] ? @((KScreenWidth-75) / 2) : @((KScreenWidth-75) / 2 + 75);
        _hideRefineInfoViewAnimation.toValue = [SystemConfigUtils isRightToLeftShow] ? @(-KScreenWidth * 0.5) : @(KScreenWidth * 1.5);
        _hideRefineInfoViewAnimation.duration = 0.25f;
        _hideRefineInfoViewAnimation.removedOnCompletion = NO;
        _hideRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
        _hideRefineInfoViewAnimation.delegate = self;
    }
    return _hideRefineInfoViewAnimation;
}
@end
