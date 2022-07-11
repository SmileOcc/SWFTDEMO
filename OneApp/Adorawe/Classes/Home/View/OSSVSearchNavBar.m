//
//  STLSearchNavigationBar.m
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchNavBar.h"
#import "STLButton.h"


@interface OSSVSearchNavBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIView                    *searchBgView;
@property (nonatomic, strong) UIImageView               *searchIconView;
@property (nonatomic, strong) UITextField               *searchField;
@property (nonatomic, strong) UIButton                  *backButton;
@property (nonatomic, strong) UIButton                  *searchButton;
@property (nonatomic, strong) UIView                    *lineView;

@end

@implementation OSSVSearchNavBar

- (instancetype)init {
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, kNavHeight);
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self addSubview:self.backButton];
        [self addSubview:self.searchBgView];
        [self.searchBgView addSubview:self.searchIconView];
        [self.searchBgView addSubview:self.searchField];
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
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.searchBgView.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
        

        
        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.searchBgView);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
            if ([self.searchButton.titleLabel.text length] > 8) {
                make.width.mas_equalTo(82);
            } else {
                make.width.mas_equalTo(65);
            }
        }];
    }
    return self;
}

- (void)becomeEditFirst {
    [self.searchField becomeFirstResponder];
}

- (void)changeKeyWordForTextField:(NSString *)keyWord{
    self.searchField.text = keyWord;
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

- (void)doneButtonAction:(UIButton *)sender{
    [self endEditing:YES];
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

- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
    self.searchField.text = searchKey;
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
        _searchField.placeholder = [NSString stringWithFormat:@"%@", STLLocalizedString_(@"search", nil)];
        _searchField.delegate = self;
        
        if (APP_TYPE == 3) {
            _searchField.tintColor = [OSSVThemesColors col_000000:1.0];
            _searchField.textColor = [OSSVThemesColors col_000000:1.0];
        }else{
            _searchField.tintColor = [OSSVThemesColors col_999999];
            _searchField.textColor = [OSSVThemesColors col_262626];
            _searchField.backgroundColor = OSSVThemesColors.col_F7F7F7;
        }
        _searchField.font = [UIFont systemFontOfSize:14];
        _searchField.returnKeyType = UIReturnKeySearch;
        
        
//        _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
//        _searchField.leftViewMode = UITextFieldViewModeAlways;
//
//        _searchField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
//        _searchField.rightViewMode = UITextFieldViewModeAlways;
//
////        _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
////        _searchField.leftViewMode = UITextFieldViewModeAlways;
////
////        _searchField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
////        _searchField.rightViewMode = UITextFieldViewModeAlways;
//
//        STLButton *searchIcon = [STLButton buttonWithType:UIButtonTypeCustom];
//        searchIcon.frame = CGRectMake(0, 0, 31, 24);
//        searchIcon.imageRect = CGRectMake(7, 0, 24, 24);
//        searchIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [searchIcon setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateNormal];
//        [searchIcon setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateDisabled];
//        searchIcon.enabled = NO;
//
//
    
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [searchIcon convertUIWithARLanguage];
//            searchIcon.imageRect = CGRectMake(0, 0, 24, 24);
//            searchIcon.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
//            _searchField.rightView = searchIcon;
//            _searchField.rightViewMode = UITextFieldViewModeAlways;
//            _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
//            _searchField.leftViewMode = UITextFieldViewModeAlways;
//
//        } else {
//
////            _searchField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 36)];
////            _searchField.rightViewMode = UITextFieldViewModeAlways;
//
//            if (@available(iOS 13.0, *)) {
//                searchIcon.frame = CGRectMake(0, 0, 24, 24);
//                searchIcon.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
//            } else {
//                searchIcon.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//            }
//            _searchField.leftView = searchIcon;
//            _searchField.leftViewMode = UITextFieldViewModeAlways;
//        }

        [_searchField addDoneOnKeyboardWithTarget:self action:@selector(doneButtonAction:)];
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
        [_searchButton setTitleColor:OSSVThemesColors.col_2D2D2D forState:UIControlStateNormal];
        [_searchButton setTitle:STLLocalizedString_(@"search", nil) forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchDoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _searchButton;
}

- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
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

@end
