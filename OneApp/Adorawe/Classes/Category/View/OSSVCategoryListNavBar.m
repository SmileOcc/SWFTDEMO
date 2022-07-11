//
//  OSSVCategoryListNavBar.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategoryListNavBar.h"
#import "JSBadgeView.h"

@interface OSSVCategoryListNavBar ()
@property (nonatomic, strong) UIButton                  *backButton; //返回按钮
@property (nonatomic, strong) UIView                    *lineView;   //底部线条
@property (nonatomic, strong) UIButton                  *bagButton;  //购物袋
@property (nonatomic, strong) JSBadgeView               *badgeView;  //
@property (nonatomic, strong) UIView                    *searchBgView;  //搜索背景框
@property (nonatomic, strong) UIImageView               *searchIconView;  //搜索图标
@property (nonatomic, strong) UIView                    *contentBgView;  //白色背景
@property (nonatomic, strong) UIScrollView              *scrollView;

@property (nonatomic, strong) UILabel                   *contentLabel;  //文字显示
@property (nonatomic, strong) UIImageView               *closeImageView; // x图标
@end


@implementation OSSVCategoryListNavBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_CartBadge object:nil];

}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, kNavHeight);
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self addSubview:self.searchBgView];
        [self addSubview:self.backButton];
        [self addSubview:self.bagButton];
        [self addSubview:self.lineView];
        
        [self.searchBgView addSubview:self.searchIconView];
        [self.searchBgView addSubview:self.contentBgView];
        [self.contentBgView addSubview:self.scrollView];
        [self.contentBgView addSubview:self.closeImageView];
        [self.scrollView    addSubview:self.contentLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.bagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
        make.width.mas_equalTo(30);
    }];

    
    [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-6);
        make.trailing.mas_equalTo(self.bagButton.mas_leading).offset(-6);
        make.height.mas_equalTo(@(NavBarSearchHeight));
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(-7);
    }];

    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.equalTo(1);
    }];
    
    [self.searchIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.searchBgView.mas_leading).offset(14);
        make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
        make.size.equalTo(CGSizeMake(18, 18));
    }];
    
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.searchIconView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
        make.trailing.mas_lessThanOrEqualTo(self.searchBgView.mas_trailing).offset(-48);
        make.height.equalTo(24);
    }];

    [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(12);
        make.top.bottom.mas_equalTo(self.contentBgView);
        make.trailing.mas_equalTo(self.closeImageView.mas_leading).offset(-5);

    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.scrollView);
        make.centerY.mas_equalTo(self.scrollView.mas_centerY);
    }];


//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(12);
//        make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
//        make.trailing.mas_equalTo(self.closeImageView.mas_leading).offset(-5);
//    }];

}
#pragma mark ----赋值
- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    self.contentLabel.text = searchKey;
    if (searchKey.length) {
        CGSize s = [searchKey sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];        
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(s.width);
        }];
        
        [self.closeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(12, 12));
        }];
    }
    
}

- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _searchBgView.backgroundColor = [OSSVThemesColors col_FFFFFF];
            UIView *underLine = [[UIView alloc] init];
            underLine.backgroundColor = [OSSVThemesColors col_000000:1.0];
            [_searchBgView addSubview:underLine];
            [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(_searchBgView.mas_leading).offset(14);
                make.trailing.equalTo(_searchBgView.mas_trailing);
                make.bottom.equalTo(_searchBgView.mas_bottom);
                make.height.equalTo(1);
            }];
        }else{
            _searchBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
            _searchBgView.layer.cornerRadius = NavBarSearchHeight / 2.0;
            _searchBgView.layer.masksToBounds = YES;
        }
        
        _searchBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBgTap:)];
        [_searchBgView addGestureRecognizer:tapges];
    }
    return _searchBgView;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _lineView;
}


- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"detail_arrow_left_black"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
}

- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_gray"]];
    }
    return _searchIconView;
}


- (UIButton *)bagButton {
    if (!_bagButton) {
        _bagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bagButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_bagButton setImage:STLImageWithName(@"bag_new") forState:UIControlStateNormal];
        [_bagButton addTarget:self action:@selector(jumpToCartVc) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _bagButton;
}

//购物车数量
- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.bagButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.bagButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(12), -10);
        }
        
        _badgeView.userInteractionEnabled = NO;
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;
    }
    return _badgeView;
}


- (void)showCartCount {
    NSInteger allGoodsCount = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
    self.badgeView.badgeText = nil;
    if (allGoodsCount > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [[UIView alloc] init];
        if (APP_TYPE == 3) {
            _contentBgView.backgroundColor = OSSVThemesColors.col_C4C4C4;
        }else{
            _contentBgView.backgroundColor = [UIColor whiteColor];
        }
        
        _contentBgView.layer.cornerRadius = 12;
        _contentBgView.layer.masksToBounds = YES;
        _contentBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchContenViewTap)];
        [_contentBgView addGestureRecognizer:tapges];

    }
    return _contentBgView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        if (APP_TYPE == 3) {
            _contentLabel.textColor = OSSVThemesColors.col_FFFFFF;
        }else{
            _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        }
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:12];
    }
    return _contentLabel;
}

- (UIImageView *)closeImageView {
    if (!_closeImageView) {
        _closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_close"]];
    }
    return _closeImageView;
}

#pragma mark -----点击事件
- (void)refreshBagValues {
    [self showCartCount];
}

- (void)becomeEditFirst {

}


- (void)cancelButtonAction:(UIButton *)sender {
    if (self.searchInputCancelCompletionHandler) {
        self.searchInputCancelCompletionHandler();
    }
}

- (void)jumpToCartVc {
    if (self.tapBagButtonCompletionHandler) {
        self.tapBagButtonCompletionHandler();
    }
}

- (void)searchBgTap:(NSString *)searchKey {
    searchKey = self.searchKey;
    if (self.tapSerachBgViewCompletionHandler) {
        self.tapSerachBgViewCompletionHandler(searchKey);
    }
}

- (void)searchContenViewTap {
    NSString *searchKey =  STLLocalizedString_(@"search", nil);
    if (self.tapContentbgViewCompletionHandler) {
        self.tapContentbgViewCompletionHandler(searchKey);
    }
}
@end
