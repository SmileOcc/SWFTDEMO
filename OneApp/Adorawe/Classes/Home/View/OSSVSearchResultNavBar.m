//
//  STLSearchResultNavigationBar.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/5/14.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSearchResultNavBar.h"
#import "STLButton.h"
#import "JSBadgeView.h"


@interface OSSVSearchResultNavBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIView                    *searchBgView;
@property (nonatomic, strong) UIImageView               *searchIconView;

@property (nonatomic, strong) UIButton                  *backButton;
@property (nonatomic, strong) UIButton                  *searchButton;
@property (nonatomic, strong) UIView                    *lineView;
@property (nonatomic, strong) JSBadgeView               *badgeView;


@end

@implementation OSSVSearchResultNavBar

- (instancetype)init {
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, kNavHeight);
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self addSubview:self.backButton];
        [self addSubview:self.searchBgView];
        [self.searchBgView addSubview:self.searchIconView];
        [self.searchBgView addSubview:self.searchField];
        [self.searchBgView addSubview:self.searchContenView];
        [self addSubview:self.searchButton];
        
        [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-6);
            make.trailing.mas_equalTo(self.searchButton.mas_leading).offset(-6);
            make.height.mas_equalTo(@(NavBarSearchHeight));
            make.leading.mas_equalTo(self.backButton.mas_trailing).offset(-7);
        }];
        
        [self.searchIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.searchBgView.mas_leading).offset(14);
            make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        
        [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
            make.trailing.mas_equalTo(self.searchBgView.mas_trailing).offset(-2);
            make.height.mas_equalTo(NavBarButtonSize);
            make.leading.mas_equalTo(self.searchIconView.mas_trailing).offset(2);
        }];
        
        [self.searchContenView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.searchIconView.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
            make.trailing.mas_lessThanOrEqualTo(self.searchBgView.mas_trailing).offset(-48);
            make.height.equalTo(24);
        }];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
        

        
        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.searchBgView);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
//            if ([self.searchButton.titleLabel.text length] > 8) {
//                make.width.mas_equalTo(82);
//            } else {
//                make.width.mas_equalTo(65);
//            }
            make.width.mas_equalTo(30);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
    }
    return self;
}

- (void)becomeEditFirst {
    [self.searchField becomeFirstResponder];
}

#pragma mark - interface methods
- (void)clearSearchInfoOption {
    self.searchField.text = @"";
}

#pragma mark - action methods
- (void)cancelButtonAction:(UIButton *)sender {
    if (self.searchInputCancelCompletionHandler) {
        self.searchInputCancelCompletionHandler();
    }
}

#pragma mark ---点击完成， 或者搜索的block
- (void)searchDoneButtonAction:(UIButton *)sender {
    [self endEditing:YES];
    if (self.searchInputReturnCompletionHandler) {
        if (STLIsEmptyString(self.searchField.text)) {
            self.searchInputReturnCompletionHandler(self.inputPlaceHolder);
        } else {
            self.searchInputReturnCompletionHandler(self.searchField.text);
        }
    }
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@" "]) {
        return NO;
    }
    NSString *key;
    if ([string isEqualToString:@""]) {
        key = [textField.text substringToIndex:textField.text.length - 1];
    } else {
        key = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    
    if ([string isEqualToString:@"\n"]) {
        [self searchDoneButtonAction:nil];
    } else {
        //优化了延迟500毫秒记录输入内容，发起请求
        [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(afterDelayRequest:) withObject:key afterDelay:0.5];

    }
    return YES;
}

#pragma mark ---输入时候的联想搜索的block
- (void)afterDelayRequest:(NSString *)key {
    NSLog(@"输入的信息：%@", key);
    if (self.searchInputSearchKeyCompletionHandler) {
                    self.searchInputSearchKeyCompletionHandler(key);
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.searchInputSearchKeyCompletionHandler) {
        self.searchInputSearchKeyCompletionHandler(@"");
    }
    return YES;
}

- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    self.searchField.placeholder = inputPlaceHolder;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.searchInputReturnCompletionHandler) {
        if (STLIsEmptyString(self.searchField.text)) {
            self.searchInputReturnCompletionHandler(self.inputPlaceHolder);
        } else {
            self.searchInputReturnCompletionHandler(self.searchField.text);
        }
    }
    return YES;
}


//- (NSString *)searchKey {
//    return STLToString(self.searchField.text);
//}
//
//- (void)setSearchKey:(NSString *)searchKey{
//    self.searchField.text = STLToString(searchKey);
//}

- (void)searchBgTap {
    NSString *contentString = @"";
    if (self.searchField.text.length) {
        contentString = self.searchField.text;
    }
    if (self.searchContenView.contentLabel.text.length) {
        contentString = self.searchContenView.contentLabel.text;
    }
    if (self.tapSerachBgViewCompletionHandler) {
        self.tapSerachBgViewCompletionHandler(contentString);
    }
}

- (void)refreshBagValues {
    [self showCartCount];
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

#pragma mark --- bradge

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.searchButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.searchButton alignment:JSBadgeViewAlignmentTopRight];
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

- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_gray"]];
    }
    return _searchIconView;
}

- (UITextField *)searchField {
    if (!_searchField) {
        _searchField = [[UITextField alloc] initWithFrame:CGRectZero];
        
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;

        _searchField.delegate = self;
        
        _searchField.font = [UIFont systemFontOfSize:14];
        _searchField.returnKeyType = UIReturnKeySearch;
        
        if (APP_TYPE == 3) {
            _searchField.tintColor = [OSSVThemesColors col_000000:1.0];
            _searchField.textColor = [OSSVThemesColors col_000000:1.0];
        }else{
            _searchField.backgroundColor = OSSVThemesColors.col_F7F7F7;
            _searchField.tintColor = [OSSVThemesColors col_999999];
            _searchField.textColor = [OSSVThemesColors col_262626];
        }
        

        [_searchField addDoneOnKeyboardWithTarget:self action:@selector(searchDoneButtonAction:)];
        [_searchField convertTextAlignmentWithARLanguage];
        
    }
    return _searchField;
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

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        [_searchButton setTitleColor:OSSVThemesColors.col_2D2D2D forState:UIControlStateNormal];
//        [_searchButton setTitle:STLLocalizedString_(@"search", nil) forState:UIControlStateNormal];
        [_searchButton setImage:STLImageWithName(@"bag_new") forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchDoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _searchButton;
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
        }
        _searchBgView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBgTap)];
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

- (SearchContentView *)searchContenView {
    if (!_searchContenView) {
        _searchContenView = [[SearchContentView alloc] init];
        if (APP_TYPE == 3) {
            _searchContenView.backgroundColor = OSSVThemesColors.col_C4C4C4;
        }else{
            _searchContenView.backgroundColor = [UIColor whiteColor];
        }
        
        _searchContenView.layer.cornerRadius = 12;
        _searchContenView.layer.masksToBounds = YES;
        _searchContenView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchContenViewTap)];
        [_searchContenView addGestureRecognizer:tapges];

       }
    return _searchContenView;
}

#pragma mark -- 点击文本内容返回上一页
- (void)searchContenViewTap {
    if (self.searchInputCancelCompletionHandler) {
        self.searchInputCancelCompletionHandler();
    }
}
@end


@implementation SearchContentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.imageView];
        [self.scrollView addSubview:self.contentLabel];

        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.equalTo(CGSizeMake(12, 12));
        }];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.top.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.imageView.mas_leading).offset(-5);

        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.scrollView);
            make.centerY.mas_equalTo(self.scrollView.mas_centerY);
        }];

    }
    return self;
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
        
        if (APP_TYPE == 3) {
            _contentLabel.textColor = OSSVThemesColors.col_FFFFFF;
        }else{
            _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        }
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.userInteractionEnabled = YES;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _contentLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            _contentLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }
    return _contentLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_close"]];
    }
    return _imageView;
}

- (void)setContentString:(NSString *)contentString {
    _contentString = contentString;
    self.contentLabel.text = contentString;
    if (contentString.length) {
        CGSize s = [contentString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(s.width);
        }];
        
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(12, 12));
        }];
    }
}
@end
