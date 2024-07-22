//
//  ZFHomeNavigationBar.m
//  ZZZZZ
//
//  Created by YW on 18/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeNavigationBar.h"
#import "YWLocalHostManager.h"
#import "ZFSkinViewModel.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFStatistics.h"
#import "ZFFrameDefiner.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFStatisticsKey.h"
#import "ZFPopDownAnimation.h"
#import "YWCFunctionTool.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "ZFHomeSearchView.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"

@interface ZFHomeNavigationBar ()
@property (nonatomic, strong) YYAnimatedImageView     *logoImageView;
@property (nonatomic, strong) ZFHomeSearchView        *searchBarView;
@property (nonatomic, strong) UIButton                *leftSearchButton;
@property (nonatomic, strong) UIButton                *leftCategoryButton;
@property (nonatomic, strong) UIButton                *rightButton;
@property (nonatomic, strong) UIView                  *bottomLine;
@property (nonatomic, strong) UIView                  *backgroundView;
@property (nonatomic, assign) BOOL                    finishedAnimation;
@property (nonatomic, assign) CGFloat                 contentViewOffsetY;
@end

@implementation ZFHomeNavigationBar

- (instancetype)init {
    if (self = [super init]) {
        self.finishedAnimation = YES;
        self.userInteractionEnabled = YES;
        CGFloat barHeight = 44 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        self.frame = CGRectMake(0.0, 0.0, KScreenWidth, barHeight);
        self.userInteractionEnabled = YES;
        [self setupView];
        [self layoutView];
        
        /**
         * ❗️❗️❗️警告不要修改这个❗️❗️❗️
         * 开发时: 非线上发布环境显示切换环境
         */
        if ([YWLocalHostManager isDistributionOnlineRelease]) {
            YWLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        } else {
            // 开发时设置可以切换任何环境
            [self addGestures];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kCartNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView {
    [self addSubview:self.backgroundView];
    [self addSubview:self.logoImageView];
    [self addSubview:self.searchBarView];
    [self addSubview:self.leftSearchButton];
    [self addSubview:self.leftCategoryButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.bottomLine];
    
    self.backgroundColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
}

- (void)layoutView {
    NSInteger top = kiphoneXTopOffsetY+3;
    NSInteger margin = 14;

    self.backgroundView.frame = self.bounds;
    self.leftSearchButton.frame = CGRectMake(margin, top, NavBarButtonSize, NavBarButtonSize);
    self.leftCategoryButton.frame = self.leftSearchButton.frame;
    self.rightButton.frame = CGRectMake(KScreenWidth - NavBarButtonSize - margin, top+1.5, NavBarButtonSize, NavBarButtonSize);
    self.bottomLine.frame = CGRectMake(0, (CGFloat)(self.bounds.size.height - 0.5), KScreenWidth, 0.5);
    
    // 默认先把搜索栏显示在屏幕外
    CGFloat searchBarWidth = KScreenWidth - (margin + NavBarButtonSize + margin * 2);
    CGFloat defaultSearchX = - (margin + searchBarWidth);
    self.searchBarView.frame = CGRectMake(defaultSearchX, top, searchBarWidth, NavBarButtonSize);
    
    /**
     * 🌶🌶🌶🌶注意：这里暂时不要用约束🌶🌶🌶🌶
     * 若使用约束，在未打开app的情况下，通过deplink、推送跳转，
     * 结果：首页会缺失tab视图，及界面不可点击，
     * 原因：与使用下方法引起的
     * [self.rightButton showShoppingCarsBageValue:[GetUserDefault(kCollectionBadgeKey) integerValue]];
     * 原因分析: 是对按钮图片进行了处理，why
     *
     */
}

#pragma mark - setter
- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    
    if (ZFIsEmptyString(inputPlaceHolder)) {
        self.searchBarView.inputPlaceHolder = ZFLocalizedString(@"homeSearchTitle", nil);
    } else {
        self.searchBarView.inputPlaceHolder = inputPlaceHolder;
    }
}

#pragma mark - Notification
- (void)refreshBagValues {
    [self setBagValues];
    [ZFPopDownAnimation popDownRotationAnimation:self.rightButton];
}

- (void)updateNavigationBar:(BOOL)needShow {
    if (needShow) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ZFSkinModel *appHomeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
            UIImage *searchIcon   = [ZFSkinViewModel searchImage];
            UIImage *bagIcon      = [ZFSkinViewModel bagImage];
            YYImage *homeLogo     = [ZFSkinViewModel logoImage];
            UIImage *navigationBg = [ZFSkinViewModel navigationBgImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self zf_setLogoImage:homeLogo];
                [self zf_setLeftButtonWithImage:searchIcon];
                [self zf_setRightButtonWithImage:bagIcon];
                if (appHomeSkinModel.bgUseType == 1) {
                    [self zf_setBarBackgroundColor:[UIColor colorWithHexString:appHomeSkinModel.bgColor]];
                } else {
                    [self zf_setBarBackgroundImage:navigationBg];
                }
            });
        });
    } else { //换肤样式 -> 默认样式
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundColor = [UIColor whiteColor];
            self.backgroundView.backgroundColor = [UIColor whiteColor];
            
            UIImage *image = [UIImage imageNamed:@"ZZZZZ"];
            self.logoImageView.image  = image;
            self.logoImageView.frame  = CGRectMake(0, kiphoneXTopOffsetY, image.size.width, image.size.height);
            self.logoImageView.center = CGPointMake(self.centerX, self.rightButton.centerY);
            [self.leftSearchButton setImage:self.searchBtnDefaultImage forState:UIControlStateNormal];
            [self.leftCategoryButton setImage:self.categoryBtnDefaultImage forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        });
    }
}

- (UIImage *)searchBtnDefaultImage {
    return [UIImage imageNamed:@"home_search"];
}

- (UIImage *)categoryBtnDefaultImage {
    return [UIImage imageNamed:@"home_category"];
}

#pragma mark - Public method
- (void)zf_setBarBackgroundColor:(UIColor *)color {
    self.backgroundView.backgroundColor = color;
}

- (void)zf_setBarBackgroundImage:(UIImage *)image {
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self zf_setBottomLineHidden:YES];
    //self.layer.contents = (id)image.CGImage;
    self.image = image; //V5.0.0处理为支持gif图片
}

- (void)zf_setLogoImage:(YYImage *)logoImage {
    if (logoImage) {
        self.logoImageView.image  = logoImage;
        self.logoImageView.size   = logoImage.size;
        self.logoImageView.center = CGPointMake(self.centerX, self.rightButton.centerY);
    }
}

- (void)zf_setBottomLineHidden:(BOOL)hidden {
    self.bottomLine.hidden = hidden;
}

- (void)zf_setBackgroundAlpha:(CGFloat)alpha {
    self.backgroundView.alpha = alpha;
    self.layer.opacity = alpha;
    self.bottomLine.alpha = alpha;
}

- (void)zf_showInputView:(BOOL)showSearchView offsetY:(CGFloat)offsetY {
    if (!self.finishedAnimation) {
        self.contentViewOffsetY = offsetY;
        return;
    } else {
        self.contentViewOffsetY = -1;
    }
    self.finishedAnimation = NO;
    CGFloat firstDuration = showSearchView ? 0.2 : 0.5;
    CGFloat secondDuration = showSearchView ? 0.5 : 0.2;
    YWLog(@"zf_showInputView===不会死循环");
    
    [UIView animateWithDuration:firstDuration animations:^{
        self.logoImageView.alpha = showSearchView ? 0.0 : 1.0;
        if (showSearchView) {
            [self showLeftSearchButton:NO];
        } else {
            [self showSearchBarView:NO];
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:secondDuration animations:^{
            if (showSearchView) {
                [self showSearchBarView:YES];
            } else {
                [self showLeftSearchButton:YES];
            }
        } completion:^(BOOL finished) {
            self.finishedAnimation = YES;
            
            if (self.contentViewOffsetY != -1 ) {
                BOOL show = self.contentViewOffsetY > (STATUSHEIGHT + 44);
                [self zf_showInputView:show offsetY:-1];
            }
        }];
    }];
}

- (void)showLeftSearchButton:(BOOL)showButton {
    self.leftSearchButton.layer.transform = showButton ? CATransform3DIdentity : CATransform3DMakeScale(0.5, 0.5, 1);
    self.leftSearchButton.alpha = showButton ? 1.0 : 0.0;
}

- (void)showSearchBarView:(BOOL)showSearchView {
    NSInteger margin = 14;
    CGFloat searchBarWidth = KScreenWidth - (margin * 2 + NavBarButtonSize);
    self.searchBarView.x = showSearchView ? margin : -(margin + searchBarWidth);
}

- (void)zf_setTintColor:(UIColor *)color {
    if (color) {
        [self.leftSearchButton setTitleColor:color forState:UIControlStateNormal];
        [self.leftCategoryButton setTitleColor:color forState:UIControlStateNormal];
        [self.rightButton setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)zf_setLeftButtonWithImage:(UIImage *)image {
    if (image) {
        [self.leftSearchButton setImage:image forState:UIControlStateNormal];
        [self.leftSearchButton setImage:image forState:UIControlStateHighlighted];
        [self.leftCategoryButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)zf_setRightButtonWithImage:(UIImage *)image {
    if (image) {
        [self.rightButton setImage:image forState:UIControlStateNormal];
        [self.rightButton setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)setBagValues {
    [self.rightButton showShoppingCarsBageValue:[GetUserDefault(kCollectionBadgeKey) integerValue]];
}

#pragma mark - Action
- (void)clickButtonAction:(UIButton *)button {
    [self targetActionType:button.tag];
}

- (void)targetActionType:(HomeNavigationBarActionType)actionType {
    if (actionType > HomeNavBarRightButtonAction) return;
    
    switch (actionType) {
        case HomeNavBarLeftButtonAction://左侧按钮
        {
            [ZFStatistics eventType:ZF_Home_Search_type];
        }
            break;
        case HomeNavBarRightButtonAction://右侧按钮
        {
            [ZFStatistics eventType:ZF_Home_Cars_type];
        }
            break;
        case HomeNavBarSearchCategoryButtonAction://搜索分类按钮
        {
            [ZFStatistics eventType:ZF_Category_Search_type];
        }
            break;
        case HomeNavBarSearchImageButtonAction://搜图按钮
        {
            [ZFStatistics eventType:ZF_Category_SearchImage_type];
        }
            break;
        default:
            break;
    }
    if (self.navigationBarActionBlock) {
        self.navigationBarActionBlock(actionType);
    }
}

/**
 * 切换开发环境按钮
 */
- (void)addGestures {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:[YWLocalHostManager class] action:@selector(changeLocalHost)];
    [self.logoImageView addGestureRecognizer:tapGesture];
}

#pragma mark - Getter
- (UIButton *)leftSearchButton {
    if (!_leftSearchButton) {
        _leftSearchButton = [[UIButton alloc] init];
        [_leftSearchButton setImage:self.searchBtnDefaultImage forState:UIControlStateNormal];
        [_leftSearchButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftSearchButton.imageView.contentMode = UIViewContentModeCenter;
        _leftSearchButton.tag = HomeNavBarLeftButtonAction;
        [_leftSearchButton setEnlargeEdge:10];
    }
    return _leftSearchButton;
}

- (UIButton *)leftCategoryButton {
    if (!_leftCategoryButton) {
        _leftCategoryButton = [[UIButton alloc] init];
        [_leftCategoryButton setImage:self.categoryBtnDefaultImage forState:UIControlStateNormal];
        [_leftCategoryButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftCategoryButton.imageView.contentMode = UIViewContentModeCenter;
        _leftCategoryButton.tag = HomeNavBarLeftButtonAction;
        [_leftCategoryButton setEnlargeEdge:10];
        _leftCategoryButton.adjustsImageWhenHighlighted = NO;
        _leftCategoryButton.alpha = 0.0;
    }
    return _leftCategoryButton;
}

- (YYAnimatedImageView *)logoImageView {
    if (!_logoImageView) {
        UIImage *image = [UIImage imageNamed:@"ZZZZZ"];
        _logoImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0,kiphoneXTopOffsetY, image.size.width, image.size.height)];
        _logoImageView.center = CGPointMake(self.frame.size.width / 2, kiphoneXTopOffsetY + (self.frame.size.height - kiphoneXTopOffsetY) / 2);
        _logoImageView.image  = image;
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.userInteractionEnabled = YES;
    }
    return _logoImageView;
}

- (ZFHomeSearchView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[ZFHomeSearchView alloc] initWithFrame:CGRectZero];
        // 换肤
        [_searchBarView zfChangeSkinToCustomNavgationBar];
        
        @weakify(self);
        // 搜索
        _searchBarView.categoryActionSearchInputCompletionHandler = ^{
            @strongify(self);
            [self targetActionType:HomeNavBarSearchCategoryButtonAction];
        };
        // 搜图
        _searchBarView.categoryActionSearchImageCompletionHandler = ^{
            @strongify(self);
            [self targetActionType:HomeNavBarSearchImageButtonAction];
        };
    }
    return _searchBarView;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;
        _rightButton.tag = HomeNavBarRightButtonAction;
        [_rightButton setEnlargeEdge:10];
    }
    return _rightButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = ZFCOLOR(209, 209, 209, 1.0);
    }
    return _bottomLine;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}

@end
