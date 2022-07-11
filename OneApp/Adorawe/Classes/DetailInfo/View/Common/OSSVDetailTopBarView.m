//
//  GoodsDetailTopView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailTopBarView.h"
#import "AppDelegate+STLCategory.h"
#import "UIView+WhenTappedBlocks.h"

@implementation OSSVDetailTopBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        if (APP_TYPE == 3) {
            self.backgroundColor =OSSVThemesColors.col_FFFFFF;
            [self addSubview:self.imgView];
            [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_centerX);
                make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-4);
                make.size.mas_equalTo(CGSizeMake(36, 36));
            }];
        }
        [self addSubview:self.eventView];
        [self addSubview:self.grayEvent];

        [self addSubview:self.cartAnimateView];
        [self addSubview:self.cartPositionView];
        
        [self.eventView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.grayEvent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];

        [self.cartPositionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.eventView.cartButton);
            make.size.mas_equalTo(self.eventView.cartButton);
        }];
        
        [self.cartAnimateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.eventView.cartButton);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
    }
    return self;
}



- (void)playCartAnimate:(BOOL)play {
    if (play) {
        self.cartAnimateView.hidden = NO;
        self.cartPositionView.hidden = NO;
        @weakify(self)
        [self.cartAnimateView playWithCompletion:^(BOOL flag) {
            @strongify(self)
            self.cartAnimateView.hidden = YES;
            self.cartPositionView.hidden = YES;

        }];
    } else {
        [self.cartAnimateView stop];
        self.cartAnimateView.hidden = YES;
        self.cartPositionView.hidden = YES;

    }
}

- (void)updateItemAlpha:(CGFloat)alpha {
    if (APP_TYPE == 3) {
        self.imgView.alpha = 1;//alpha;
        self.eventView.alpha = 1;
        self.eventView.backgroundColor = UIColor.clearColor;
        self.eventView.hidden = alpha <= 0 ? YES : NO;
    }else{
        self.eventView.searchBgView.alpha = alpha;
    //    self.imgView.alpha = alpha;
        self.grayEvent.alpha = 1 - alpha;
        self.eventView.alpha = alpha;
        self.eventView.hidden = alpha <= 0 ? YES : NO;
    }
    
    self.eventView.bottomLineView.alpha = alpha;
    self.eventView.bottomLineView.hidden = alpha <= 0 ? YES : NO;
}

- (void)setCartNumber:(NSInteger)cartNumber {
    _cartNumber = cartNumber;
    
    NSString *badgeText = @"";
    if (cartNumber > 0) {
        badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)cartNumber];
        if (cartNumber > 99) {
            cartNumber = 99;
            badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)cartNumber];
        }
    }
    self.badgeView.badgeText = badgeText;
    self.eventView.badgeView.badgeText = badgeText;
    self.grayEvent.badgeView.badgeText = badgeText;
}
#pragma mark - action
- (void)toucheEvent:(NSInteger )flag {
    if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVDetailTopBarViewEvent:)]) {
        [self.delegate OSSVDetailTopBarViewEvent:flag];
    }
}

#pragma mark - LazyLoad

- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = imgUrl;
    [self.imgView yy_setImageWithURL:[NSURL URLWithString:_imgUrl]
                         placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                             options:kNilOptions
                            progress:nil
                           transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                               return image;
                           }
                          completion:nil];
}

- (GoodsDetailTopBarEventView *)eventView {
    if (!_eventView) {
        _eventView = [[GoodsDetailTopBarEventView alloc] initWithFrame:CGRectZero];
        _eventView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _eventView.hidden = YES;

        @weakify(self)
        _eventView.eventBlock = ^(NSInteger tag) {
            @strongify(self)
            [self toucheEvent:tag];
        };
    }
    return _eventView;
}

- (GoodsDetailTopBarEventView *)grayEvent {
    if (!_grayEvent) {
        _grayEvent = [[GoodsDetailTopBarEventView alloc] initWithFrame:CGRectZero];
        _grayEvent.backgroundColor = [UIColor clearColor];

        @weakify(self)
        _grayEvent.eventBlock = ^(NSInteger tag) {
            @strongify(self)
            [self toucheEvent:tag];
        };
    }
    return _grayEvent;
}

- (YYAnimatedImageView *)imgView {
    if (!_imgView) {
        _imgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.cornerRadius = 18.f;
        _imgView.layer.borderColor = OSSVThemesColors.col_F5F5F5.CGColor;
        _imgView.layer.borderWidth = 0.6f;
        _imgView.layer.masksToBounds = YES;
        
    }
    return _imgView;
}

- (UIView *)cartPositionView {
    if (!_cartPositionView) {
        _cartPositionView = [[UIView alloc] initWithFrame:CGRectZero];
        _cartPositionView.backgroundColor = [OSSVThemesColors stlClearColor];
        _cartPositionView.hidden = YES;
    }
    return _cartPositionView;
}
- (MyLottieView *)cartAnimateView {
    if (!_cartAnimateView) {
        NSString *animFileName = [NSString stringWithFormat:@"carts_lottie_%@",OSSVLocaslHosstManager.appName.lowercaseString];
        _cartAnimateView = [[MyLottieView alloc] initWithFrame:CGRectZero name:animFileName];
        [_cartAnimateView convertUIWithARLanguage];
        _cartAnimateView.hidden = YES;
    }
    return _cartAnimateView;
}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.cartPositionView alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(5), 10);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.cartPositionView alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(8), -5);
        }

        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;
    }
    return _badgeView;
}

    
@end


@implementation GoodsDetailTopBarEventView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backButton];
        [self addSubview:self.cartButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.searchBgView];
        [self addSubview:self.bottomLineView];
        [self.searchBgView addSubview:self.searchImageView];
        [self.searchBgView addSubview:self.searchScrollView];
        [self.searchScrollView addSubview:self.inputField];

        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-0.5);
            make.height.equalTo(0.5);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-10);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.moreButton.mas_leading).mas_offset(-10);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.backButton.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-6);
            make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-15);
            make.height.equalTo(32);
        }];
        
        [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.leading.equalTo(self.searchBgView.mas_leading).offset(14);
            make.centerY.equalTo(self.searchBgView.mas_centerY);
            make.size.equalTo(CGSizeMake(18, 18));
        }];
        
        [self.searchScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.searchImageView.mas_trailing).offset(5);
            make.top.bottom.mas_equalTo(self.searchBgView);
            make.trailing.mas_equalTo(self.searchBgView.mas_trailing);
        }];
        
        [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self.searchScrollView);
        }];

        [self showShareRuleJudge];
//        [self changeFirstDayViewedStatus];
    }
    return self;
}

// 分享按钮动效规则
- (void)showShareRuleJudge{
    NSDate *installDate = [AppDelegate getAppInstallOrUpdateTime];
    if (installDate && [self judgeCurrentDayViewedWithDate:installDate]) {
        [self returnDefaultStatus];
    }else{
        [self changeFirstDayViewedStatus];
    }
}

// 非首日访问状态
- (void)changeFirstDayViewedStatus{
//    self.cartButton.hidden = YES;
//    self.shareImgV.hidden = NO;
//    self.shareBgV.hidden = NO;
//    [self performSelector:@selector(returnDefaultStatus) withObject:nil afterDelay:4];
}

// 恢复默认状态
- (void)returnDefaultStatus{
//    self.shareImgV.hidden = YES;
//    self.shareBgV.hidden = YES;
//    self.cartButton.hidden = NO;
}

// 判断当天是否是首日访问
- (BOOL)judgeCurrentDayViewedWithDate:(NSDate *)defaultDate{
    return [[NSCalendar currentCalendar] isDate:defaultDate inSameDayAsDate:[NSDate date]];
}

- (void)touchEvent:(UIButton*)sender {
    if (self.eventBlock) {
        self.eventBlock(sender.tag - 20000);
    }
}

- (void)cartBtnTouch:(UITapGestureRecognizer *)tap {
    if (self.eventBlock) {
        self.eventBlock(GoodsDetailTopBarEventCart);
    }
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.tag = 20000 + GoodsDetailTopBarEventBack;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _backButton.transform = CGAffineTransformMakeRotation(M_PI);
        }
        [_backButton setImage:[UIImage imageNamed:@"back_border_white"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return _backButton;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cartButton.tag = 20000 + GoodsDetailTopBarEventCart;
        [_cartButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return _cartButton;
}



//- (UIImageView *)shareImgV{
//    if (!_shareImgV) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"share_earn" ofType:@"gif"];
//        NSData *fileData = [NSData dataWithContentsOfFile:path];
//        UIImage *customImg = [UIImage yy_imageWithSmallGIFData:fileData scale:1.0];
//        _shareImgV = [UIImageView new];
//        _shareImgV.image = customImg;
//        _shareImgV.contentMode = UIViewContentModeScaleAspectFit;
//        _shareImgV.userInteractionEnabled = YES;
//    }
//    return _shareImgV;
//}
//
//- (UIView *)shareBgV{
//    if (!_shareBgV) {
//        _shareBgV = [UIView new];
//        _shareBgV.backgroundColor = [OSSVThemesColors.col_FFFFFF colorWithAlphaComponent:0.8];
//        _shareBgV.layer.cornerRadius = 20;
//        _shareBgV.layer.masksToBounds = YES;
//        _shareBgV.userInteractionEnabled = YES;
//        _shareBgV.tag = 20000 + GoodsDetailTopBarEventCart;
//        UITapGestureRecognizer *shareGifTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gifTapAction:)];
//        [_shareBgV addGestureRecognizer:shareGifTap];
//
//    }
//    return _shareBgV;
//}

- (void)gifTapAction:(UITapGestureRecognizer *)tap{
    if (self.eventBlock) {
        self.eventBlock(tap.view.tag - 20000);
    }
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.tag = 20000 + GoodsDetailTopBarEventMore;
        [_moreButton setImage:[UIImage imageNamed:@"more_border_white"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return _moreButton;
}


- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.cartButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(5), 10);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.cartButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(8), -5);
        }
        
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;
        _badgeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cartBtnTouch:)];
        [_badgeView addGestureRecognizer:tapGesture];
    }
    return _badgeView;
}


- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchBgView.alpha = 0.0;
        _searchBgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _searchBgView.layer.cornerRadius = 16;
        _searchBgView.layer.masksToBounds = YES;
        _searchBgView.userInteractionEnabled = YES;
    }
    return _searchBgView;
}

- (UIImageView *)searchImageView {
    if (!_searchImageView) {
        _searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_gray"]];
    }
    return _searchImageView;
}
//文字滚动
- (SDCycleScrollView *)searchScrollView {
    if (!_searchScrollView) {
        _searchScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@""]];
        _searchScrollView.onlyDisplayText = YES;
        _searchScrollView.backgroundColor = [UIColor clearColor];
        _searchScrollView.autoScrollTimeInterval = 2;
        _searchScrollView.titleLabelHeight = 20;
        _searchScrollView.titleLabelTextColor = OSSVThemesColors.col_B2B2B2;
        _searchScrollView.titleLabelTextFont  = [UIFont systemFontOfSize:14];
        _searchScrollView.titleLabelBackgroundColor = [UIColor clearColor];
        _searchScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
        [_searchScrollView disableScrollGesture];
    }
    return _searchScrollView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputField.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _inputField.font = [UIFont systemFontOfSize:14];
        _inputField.textColor = OSSVThemesColors.col_999999;
        _inputField.hidden = YES;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"search", nil) attributes:
        @{NSForegroundColorAttributeName:OSSVThemesColors.col_B2B2B2,
                     NSFontAttributeName:_inputField.font
             }];
        _inputField.attributedPlaceholder = attrString;
        _inputField.userInteractionEnabled = NO;
        _inputField.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _inputField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _inputField;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        _bottomLineView.hidden = YES;
    }
    return _bottomLineView;
}

- (NSMutableArray *)titleArary {
    if (!_titleArary) {
        _titleArary = [NSMutableArray array];
    }
    return _titleArary;
}

- (void)setHotWordsArray:(NSArray *)hotWordsArray {
    _hotWordsArray = hotWordsArray;
    [self.titleArary removeAllObjects];
    NSArray *subArray = [NSArray array];
    if (self.hotWordsArray.count > 3) {
       subArray = [self.hotWordsArray  subarrayWithRange:NSMakeRange(0, 3)];  //截取3个数据
    } else {
        subArray = self.hotWordsArray;
    }

    if (subArray.count) {
        for (OSSVHotsSearchWordsModel *model in subArray) {
            [self.titleArary addObject:STLToString(model.word)];
        }
        self.searchScrollView.titlesGroup = self.titleArary;
    }  else {
        //没有热词返回时候，默认为search，可以点击
        self.searchScrollView.userInteractionEnabled = YES;
        self.inputField.hidden = NO;
        @weakify(self)
        [self.inputField whenTapped:^{
            @strongify(self)
            if (self.searchBlock) {
                self.searchBlock(@"");
            }

        }];
    }
}
#pragma mark ---点击文字代理

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSString *searchKey = @"";
    if (self.titleArary.count) {
        searchKey = self.titleArary[index];
        if (self.searchBlock) {
            self.searchBlock(searchKey);
        }
    }
}

@end
