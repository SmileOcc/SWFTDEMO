//
//  CategoryRefineView.m
//  ListPageViewController
//
//  Created by YW on 29/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineContainerView.h"
#import "CategoryRefineInfoView.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"


static CGFloat const kCategoryRefineAnimatonTime = 0.25f;

static NSString *const khideRefineInfoViewAnimationIdentifier = @"khideRefineInfoViewAnimationIdentifier";
static NSString *const kshowRefineInfoViewAnimationIdentifier = @"kshowRefineInfoViewAnimationIdentifier";

@interface CategoryRefineContainerView ()<CAAnimationDelegate>
@property (nonatomic, strong) UIView                    *maskView;
@property (nonatomic, strong) CategoryRefineInfoView    *refineInfoView;
@property (nonatomic, strong) CABasicAnimation          *showRefineInfoViewAnimation;
@property (nonatomic, strong) CABasicAnimation          *hideRefineInfoViewAnimation;
@end

@implementation CategoryRefineContainerView
#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [self addSubview:self.refineInfoView];
    [self addSubview:self.maskView];
}

- (void)autoLayoutSubViews {
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.width.mas_equalTo(75);
    }];
    
    [self.refineInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).offset(75);
    }];
}

#pragma mark - Setter
-(void)setModel:(CategoryRefineSectionModel *)model {
    _model = model;
    self.refineInfoView.model = model;
}

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)selectedCustomRefineByDeeplink:(NSString *)selectedCategorys
                              priceMax:(NSString *)priceMax
                              priceMin:(NSString *)priceMin
                              hasCheck:(void(^)(void))hasCheckBlock {    
    NSArray *refineTypeArr = [selectedCategorys componentsSeparatedByString:@"~"];
    [self.refineInfoView shouldSelectedCustomRefineByDeeplink:refineTypeArr
                                                     priceMax:priceMax
                                                     priceMin:priceMin
                                                     hasCheck:hasCheckBlock];
}

#pragma mark - Public Methods
- (void)showRefineInfoViewWithAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    self.refineInfoView.hidden = NO;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:kCategoryRefineAnimatonTime animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    }];
    
    [self.refineInfoView.layer addAnimation:self.showRefineInfoViewAnimation forKey:kshowRefineInfoViewAnimationIdentifier];

}

- (void)hideRefineInfoViewViewWithAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    [UIView animateWithDuration:kCategoryRefineAnimatonTime animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }];
    [self.refineInfoView.layer addAnimation:self.hideRefineInfoViewAnimation forKey:khideRefineInfoViewAnimationIdentifier];
}

- (void)clearRefineInfoViewData {
    [self.refineInfoView clearRequestParmaters];
}


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.hideRefineViewCompletionHandler) {
        self.refineInfoView.hidden = YES;
        self.hideRefineViewCompletionHandler();
    }
}

#pragma mark - Gesture Handle
- (void)hideRefineView {
    [self hideRefineInfoViewViewWithAnimation:YES];
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

- (CategoryRefineInfoView *)refineInfoView {
    if (!_refineInfoView) {
        _refineInfoView = [[CategoryRefineInfoView alloc] init];
        _refineInfoView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _refineInfoView.hidden = NO;
        @weakify(self)
        _refineInfoView.applyRefineSelectInfoCompletionHandler = ^(NSDictionary *parms,NSDictionary *afParams) {
            @strongify(self);
            if (self.applyRefineContainerViewInfoCompletionHandler) {
                self.applyRefineContainerViewInfoCompletionHandler(parms,afParams);
            }
        };
        
        _refineInfoView.categoryRefineSelectIconCompletionHandler = ^(BOOL select) {
            @strongify(self);
            if (self.categoryRefineSelectIconCompletionHandler) {
                self.categoryRefineSelectIconCompletionHandler(select);
            }
        };
    }
    return _refineInfoView;
}

- (CABasicAnimation *)showRefineInfoViewAnimation {
    if (!_showRefineInfoViewAnimation) {
        _showRefineInfoViewAnimation = [CABasicAnimation animation];
        _showRefineInfoViewAnimation.keyPath = @"position.x";
        _showRefineInfoViewAnimation.fromValue = [SystemConfigUtils isRightToLeftShow] ? @(-KScreenWidth * 0.5) : @(KScreenWidth * 1.5);
        _showRefineInfoViewAnimation.toValue = [SystemConfigUtils isRightToLeftShow] ?  @((KScreenWidth-75) / 2) : @((KScreenWidth-75) / 2 + 75);
        _showRefineInfoViewAnimation.duration = kCategoryRefineAnimatonTime;
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
        _hideRefineInfoViewAnimation.duration = kCategoryRefineAnimatonTime;
        _hideRefineInfoViewAnimation.removedOnCompletion = NO;
        _hideRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
        _hideRefineInfoViewAnimation.delegate = self;
    }
    return _hideRefineInfoViewAnimation;
}

@end
