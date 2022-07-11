//
//  OSSVCategoryNavigatiBar.m
// XStarlinkProject
//
//  Created by odd on 2020/8/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryNavigatiBar.h"

#import "UIButton+STLCategory.h"
#import "JSBadgeView.h"

@interface OSSVCategoryNavigatiBar ()<STLCategorySearchViewDelegate>

@property (nonatomic, strong) UIButton                *rightButton;
@property (nonatomic, strong) UIView                  *bottomLine;
@property (nonatomic, strong) UIView                  *backgroundView;
@property (nonatomic, assign) BOOL                    finishedAnimation;
@property (nonatomic, assign) CGFloat                 contentViewOffsetY;
@property (nonatomic, strong) JSBadgeView             *badgeView;
@end

@implementation OSSVCategoryNavigatiBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.finishedAnimation = YES;
        self.userInteractionEnabled = YES;
        CGFloat barHeight = 44 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, barHeight);
        self.userInteractionEnabled = YES;
        [self setupView];
        [self layoutView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
    }
    return self;
}



- (void)setupView {
    [self addSubview:self.backgroundView];
    [self addSubview:self.searchBarView];
    [self addSubview:self.rightButton];
    
    self.backgroundColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
}

- (void)layoutView {
    NSInteger top = kSCREEN_BAR_HEIGHT+3+5;
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.backgroundView.mas_trailing).offset(-14);
        make.width.height.equalTo(24);
        make.top.equalTo(top);
    }];


    [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(APP_TYPE == 3 ? 0 : 12);
        make.height.equalTo(32);
        make.trailing.equalTo(self.rightButton.mas_leading).offset(-16);
        make.centerY.equalTo(self.rightButton.mas_centerY);
    }];
    
}

#pragma mark - setter
- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    
    if (STLIsEmptyString(inputPlaceHolder)) {
        self.searchBarView.inputPlaceHolder = STLLocalizedString_(@"homeSearchTitle", nil);
    } else {
        self.searchBarView.inputPlaceHolder = inputPlaceHolder;
    }
}

- (void)refreshBagValues {
    [self showCartCount];
}
- (void)showCartCount {
    NSInteger allGoodsCount = [[CartOperationManager sharedManager] cartValidGoodsAllCount];
    self.badgeView.badgeText = nil;
    if (allGoodsCount > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
}

- (void)stl_showBottomLine:(BOOL)show {
    self.bottomLine.hidden = !show;
}

- (void)clickButtonAction:(UIButton *)button {
    [self targetActionType:button.tag];
}

- (void)targetActionType:(CategoryNavBarActionType)actionType {
    if (actionType > CategorySearchAction) return;
 
    if (self.navBarActionBlock) {
        self.navBarActionBlock(actionType);
    }
}

#pragma mark - Getter

- (STLCategorySearchView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[STLCategorySearchView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE != 3) {
            _searchBarView.layer.cornerRadius = NavBarSearchHeight / 2.0;
            _searchBarView.layer.masksToBounds = YES;
        }else{
            UIView *underLine = [[UIView alloc] init];
            underLine.backgroundColor = [STLThemeColor col_000000:1.0];
            [_searchBarView addSubview:underLine];
            [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_searchBarView.mas_leading).offset(14);
                make.trailing.equalTo(_searchBarView.mas_trailing);
                make.bottom.equalTo(_searchBarView.mas_bottom);
                make.height.equalTo(1);
            }];
        }
        
        _searchBarView.delegate = self;
        // 换肤
//        [_searchBarView stlChangeSkinToCustomNavgationBar];
        
        @weakify(self);
        // 搜索
        _searchBarView.inputCompletionHandler = ^{
            @strongify(self);
            [self targetActionType:CategorySearchAction];
        };
        // 搜图
        _searchBarView.imageCompletionHandler = ^{
            @strongify(self);
        };
    }
    return _searchBarView;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] init];
        [_rightButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;
        _rightButton.tag = CategoryNavBarRightCarAction;
        [_rightButton setEnlargeEdge:10];
    }
    return _rightButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [STLThemeColor col_CCCCCC];
    }
    return _bottomLine;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    return _backgroundView;
}


- (void)stl_setBarBackgroundImage:(UIImage *)image {
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self stl_showBottomLine:NO];
    self.image = image;
}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([SystemConfigUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(16), -10);
        }
        
        _badgeView.userInteractionEnabled = NO;
        _badgeView.badgeBackgroundColor = [STLThemeColor col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [STLThemeColor stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;

    }
    return _badgeView;
}

#pragma mark ---文字滚动代理
- (void)textClick:(NSString *)searchKey {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpToSearchWithKey:)]) {
        [self.delegate jumpToSearchWithKey:searchKey];
    }
}
@end
