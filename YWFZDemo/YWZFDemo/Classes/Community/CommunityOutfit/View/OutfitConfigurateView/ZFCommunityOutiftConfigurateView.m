//
//  ZFCommunityOutiftConfigurateView.m
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutiftConfigurateView.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFOutfitRefineContainerView.h"


// 弹出触发视图
static CGFloat  CommunityOutiftTapContentHeight      = 200;
// 顶部工具条默认高度
static CGFloat  CommunityOutiftTopToolBarViewNormal  = 32;
// 顶部工具条弹出显示高度
static CGFloat  CommunityOutiftTopToolBarViewSpecial = 36;

@interface ZFCommunityOutiftConfigurateView()<ZFInitViewProtocol,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView                           *topMarkView;
@property (nonatomic, strong) UIView                           *topToolBarView;
@property (nonatomic, strong) UIButton                         *refineButton;
@property (nonatomic, strong) UIImageView                      *stateUpImageView;
@property (nonatomic, strong) UIImageView                      *stateDownImageView;

@property (nonatomic, strong) ZFOutfitRefineContainerView      *refineView;

/** 弹出触发视图*/
@property (nonatomic, strong) UIView                           *tapCoverView;
@property (nonatomic, assign) CGFloat                          startPanY;

@end

@implementation ZFCommunityOutiftConfigurateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)zfInitView {
    [self addSubview:self.topMarkView];
    [self addSubview:self.topToolBarView];
    [self addSubview:self.configureGoodsView];
    [self addSubview:self.configureBordersView];
    [self bringSubviewToFront:self.topToolBarView];
    [self addSubview:self.tapCoverView];
    
    [self.topToolBarView addSubview:self.stateUpImageView];
    [self.topToolBarView addSubview:self.stateDownImageView];
    [self.topToolBarView addSubview:self.refineButton];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionGesture:)];
    [self.tapCoverView addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionGesture:)];
    [self.tapCoverView addGestureRecognizer:tapGesture];
    
    [panGesture requireGestureRecognizerToFail:tapGesture];
    

    // topToolBar 手势
    UIPanGestureRecognizer *topPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionGesture:)];
    [self.topToolBarView addGestureRecognizer:topPanGesture];
    
    UITapGestureRecognizer *topTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionGesture:)];
    [self.topToolBarView addGestureRecognizer:topTapGesture];
    
    [topPanGesture requireGestureRecognizerToFail:topTapGesture];
}

- (void)zfAutoLayoutView {
    
    [self.tapCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(CommunityOutiftTapContentHeight);
        make.leading.trailing.top.mas_equalTo(self);
    }];
    
    [self.topToolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.height.mas_equalTo(CommunityOutiftTopToolBarViewNormal);
    }];
    
    [self.topMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.topToolBarView);
        make.bottom.mas_equalTo(self.topToolBarView.mas_bottom).offset(-5);
    }];
    
    [self.stateUpImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topToolBarView.mas_centerY);
        make.centerX.mas_equalTo(self.topToolBarView.mas_centerX);
    }];
    
    [self.stateDownImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topToolBarView.mas_centerY);
        make.centerX.mas_equalTo(self.topToolBarView.mas_centerX);
    }];
    
    [self.refineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topToolBarView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.topToolBarView.mas_centerY);
    }];
    
    [self.configureGoodsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self.topToolBarView.mas_bottom);
    }];
    
    [self.configureBordersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self.topToolBarView.mas_bottom);
    }];
}

#pragma mark - Action

- (void)hideRefineView {
    if (_refineView && !_refineView.isHidden) {
        _refineView.hidden = YES;
        [self.refineView hideViewAnimation:YES];
    }
}

- (void)refineButtonShow:(BOOL)isShow {
    
    if (!self.configureGoodsView.isHidden
        && self.alterState == OutiftConfigurateAlterStateUP
        && self.configureGoodsView.menuView.datasArray.count > 0) {
        self.refineButton.hidden = isShow ? NO : YES;
    } else {
        self.refineButton.hidden = YES;
    }
}

- (void)actionRefine:(UIButton *)sender {

    if (!self.refineView.superview) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.refineView];
        
        CGRect selfRect = [self.superview convertRect:self.frame toView:WINDOW];
        CGFloat selfMinY = CGRectGetMinY(selfRect);
        [self.refineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(selfMinY, 0, 0, 0));
        }];
    }
    
    self.refineView.model = [self.configureGoodsView currentGoodsRefine];
    self.refineView.hidden = NO;
    [self.refineView showViewAnimation:YES];
    
}

- (void)actionGesture:(UIGestureRecognizer *)gesture {

    UIView *touchView = gesture.view;
    if (touchView == self.topToolBarView) {
        
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            YWLog(@"----------topToolBarView tap---");
            
            [self actionShow];
            
        } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            
            UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            
            if (velocity.y > 0) {//向下滑动
                
                switch (gesture.state) {
                    case UIGestureRecognizerStateBegan: {
                        self.startPanY = velocity.y;
                        break;
                    }
                    case UIGestureRecognizerStateChanged: {
                        CGFloat distanceY = velocity.y - self.startPanY;
                        YWLog(@"----topToolBarView  %f  - %f = %f",velocity.y,self.startPanY,distanceY);
                        if (distanceY > 1) {
                            self.startPanY = 30000;
                            [self actionShow];
                        }
                        break;
                    }
                    case UIGestureRecognizerStateEnded: {
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        return;
    }
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        YWLog(@"----------cover tap---");

        [self actionShow];
        
    } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
        CGPoint velocity = [panGesture velocityInView:panGesture.view];
        
        if (velocity.y < 0) {//向上滑动
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan: {
                    self.startPanY = velocity.y;
                    break;
                }
                case UIGestureRecognizerStateChanged: {
                    CGFloat distanceY = self.startPanY - velocity.y;
                    YWLog(@"---- %f  - %f = %f",self.startPanY,velocity.y,distanceY);
                    if (distanceY < -1) {
                        self.startPanY = 3000;
                        [self actionShow];
                    }
                    break;
                }
                case UIGestureRecognizerStateEnded: {
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)actionShow {

    BOOL isShow = self.alterState == OutiftConfigurateAlterStateDown ? YES : NO;
    // 是否显示那个圆角半透明图层
    if (!isShow) {
        [self updateTopMarkAlppa:0];
    }
    if (self.tapShowBlock) {
        self.tapShowBlock(isShow);
        self.alterState = isShow ? OutiftConfigurateAlterStateUP : OutiftConfigurateAlterStateDown;
    }
}


- (void)updateContentView:(BOOL)isShow {
    self.tapCoverView.hidden = isShow ? YES : NO;
    self.alterState = isShow ? OutiftConfigurateAlterStateUP : OutiftConfigurateAlterStateDown;
    
    self.stateUpImageView.hidden = isShow;
    self.stateDownImageView.hidden = !isShow;
    
    if (self.alterState == OutiftConfigurateAlterStateDown) {
        [self.topToolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CommunityOutiftTopToolBarViewNormal);
        }];
    } else {
        [self.topToolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CommunityOutiftTopToolBarViewSpecial);
        }];
    }
    
    [self.configureGoodsView showMenuView:isShow];
    [self.configureBordersView showMenuView:isShow];
    
    [self refineButtonShow:isShow];
    
    // 处理筛选视图已经显示，需要隐藏，
    [self hideRefineView];
}

- (void)updateTopMarkAlppa:(CGFloat)alpha {
    self.topMarkView.alpha = alpha;
}

- (void)selectBottomMenuIndex:(NSInteger)index {
    
    NSInteger currentTag = 20190 + index;
    if (self.configureGoodsView.tag == currentTag) {
        self.configureGoodsView.hidden = NO;
        self.configureBordersView.hidden = YES;
        [self refineButtonShow:YES];
        
    } else if (self.configureBordersView.tag == currentTag) {
        self.configureGoodsView.hidden = YES;
        self.configureBordersView.hidden = NO;
        [self refineButtonShow:NO];
    }
    
}
#pragma mark - Property Method

- (UIView *)topMarkView {
    if (!_topMarkView) {
        _topMarkView = [[UIView alloc] initWithFrame:CGRectZero];
        _topMarkView.backgroundColor = ZFC0x000000_04();
        _topMarkView.alpha = 0;
    }
    return _topMarkView;
}

- (UIView *)topToolBarView {
    if (!_topToolBarView) {
        _topToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CommunityOutiftTopToolBarViewSpecial)];
        [_topToolBarView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(14, 14)];
        _topToolBarView.backgroundColor = ZFC0xFFFFFF();
    }
    return _topToolBarView;
}

- (ZFCommunityOutiftConfigurateGoodsView *)configureGoodsView {
    if (!_configureGoodsView) {
        _configureGoodsView = [[ZFCommunityOutiftConfigurateGoodsView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.frame) - CommunityOutiftTopToolBarViewSpecial)];
        _configureGoodsView.tag = 20190;
        _configureGoodsView.backgroundColor = ZFC0xFFFFFF();
        
        @weakify(self)
        _configureGoodsView.selectBlock = ^(ZFGoodsModel *goodModel) {
            @strongify(self)
            if (self.selectGoodsBlock) {
                self.selectGoodsBlock(goodModel);
            }
            [self actionShow];
        };
        
        _configureGoodsView.menuDatasBlock = ^(BOOL hasData) {
            @strongify(self)
            [self refineButtonShow:hasData];
        };
    }
    return _configureGoodsView;
}

- (ZFCommunityOutiftConfigurateBordersView *)configureBordersView {
    if (!_configureBordersView) {
        _configureBordersView = [[ZFCommunityOutiftConfigurateBordersView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.frame) - CommunityOutiftTopToolBarViewSpecial)];
        _configureBordersView.hidden = YES;
        _configureBordersView.tag = 20191;
        _configureBordersView.backgroundColor = ZFC0xFFFFFF();
        
        @weakify(self)
        _configureBordersView.selectBlock = ^(ZFCommunityOutfitBorderModel * _Nonnull borderModel) {
            @strongify(self)
            if (self.selectBorderBlock) {
                self.selectBorderBlock(borderModel);
            }
            [self actionShow];
        };
    }
    return _configureBordersView;
}

- (UIView *)tapCoverView {
    if (!_tapCoverView) {
        _tapCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CommunityOutiftTapContentHeight)];
    }
    return _tapCoverView;
}


- (UIButton *)refineButton {
    if (!_refineButton) {
        _refineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refineButton.frame = CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize);
        [_refineButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [_refineButton addTarget:self action:@selector(actionRefine:) forControlEvents:UIControlEventTouchUpInside];
        [_refineButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _refineButton.hidden = YES;
    }
    return _refineButton;
}

- (ZFOutfitRefineContainerView *)refineView {
    if (!_refineView) {
        _refineView = [[ZFOutfitRefineContainerView alloc] initWithFrame:CGRectZero];
        _refineView.backgroundColor = [UIColor clearColor];
        @weakify(self)
        _refineView.hideBlock = ^{
            @strongify(self)
            [self.refineView removeFromSuperview];
        };
        _refineView.applyBlock = ^(NSDictionary * _Nonnull parms) {
            @strongify(self)
            [self.refineView hideViewAnimation:YES];
            [self.configureGoodsView refineCurrentSelectAttr:ZFToString(parms[@"selected_attr_list"])];
        };
        _refineView.selectBlock = ^(BOOL selelct) {
            
        };
        
        _refineView.closeBlock = ^(BOOL close) {
            @strongify(self)
            [self.refineView hideViewAnimation:YES];
        };
    }
    return _refineView;
}

- (UIImageView *)stateUpImageView {
    if (!_stateUpImageView) {
        _stateUpImageView = [[UIImageView alloc] init];
        _stateUpImageView.image = [UIImage imageNamed:@"community_configurate_bar"];
    }
    return _stateUpImageView;
}

- (UIImageView *)stateDownImageView {
    if (!_stateDownImageView) {
        _stateDownImageView = [[UIImageView alloc] init];
        _stateDownImageView.image = [UIImage imageNamed:@"community_configurate_down"];
        _stateDownImageView.hidden = YES;
    }
    return _stateDownImageView;
}
@end
