//
//  OSSVCategorySearchsView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorySearchsView.h"
#import "SDCycleScrollView.h"
#import "UIView+WhenTappedBlocks.h"


@interface OSSVCategorySearchsView() <UITextFieldDelegate, SDCycleScrollViewDelegate>
@property (nonatomic, strong) UIView                *maskInputView;
@property (nonatomic, strong) UIImageView           *searchView;
@property (nonatomic, strong) UITextField           *inputField;
@property (nonatomic, strong) BigClickAreaButton    *searchImageButton;
@property (nonatomic, strong) SDCycleScrollView     *searchScroll; //搜索文字滚动
@property (nonatomic, strong) NSArray               *searchKeyArray;
@property (nonatomic, strong) NSMutableArray        *titleGroupArray;
@end

@implementation OSSVCategorySearchsView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        _searchKeyArray = @[@"看到开打开打", @"kkadfasadfasdfas", @"打卡机奥兰多市科技发生的"];

        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.inputCompletionHandler) {
        self.inputCompletionHandler();
    }
}

- (void)showPickerViewController {
    if (self.imageCompletionHandler) {
        self.imageCompletionHandler();
    }
}

#pragma mark - <STLInitViewProtocol>
- (void)stlInitView {
    if (APP_TYPE != 3) {
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    [self addSubview:self.maskInputView];
    [self.maskInputView addSubview:self.searchView];
    [self.maskInputView addSubview:self.searchScroll];
    [self.searchScroll addSubview:self.inputField];
//    [self.maskInputView addSubview:self.searchImageButton];
}

- (void)stlAutoLayoutView {
    [self.maskInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(5);
        make.trailing.mas_equalTo(self).offset(-7);
        make.height.mas_equalTo(NavBarButtonSize);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.maskInputView.mas_leading).offset(9);
        make.size.equalTo(CGSizeMake(18, 18));
    }];
    
    [self.searchScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.top.bottom.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.searchView.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.maskInputView.mas_trailing).offset(-5);
    }];

    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
//    [self.searchImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.mas_equalTo(0);
//        make.centerY.mas_equalTo(self.maskInputView);
//        make.size.mas_equalTo(CGSizeMake(24, 24));
//    }];
    
}

#pragma mark - Public method
- (void)subViewWithAlpa:(CGFloat)alpha {
    self.alpha = alpha;
}
- (void)showSearchPhotoImage:(BOOL)show {
    self.searchImageButton.hidden = !show;
}

#pragma mark - setter
- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    self.inputField.text = inputPlaceHolder;
    self.inputField.textColor = OSSVThemesColors.col_999999;
}

#pragma mark - getter
- (BigClickAreaButton *)searchImageButton {
    if (!_searchImageButton) {
        _searchImageButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _searchImageButton.adjustsImageWhenHighlighted = NO;
        [_searchImageButton setImage:[UIImage imageNamed:@"category_searchImage"] forState:UIControlStateNormal];
        [_searchImageButton addTarget:self action:@selector(showPickerViewController) forControlEvents:UIControlEventTouchUpInside];
        _searchImageButton.hidden = YES;
        _searchImageButton.clickAreaRadious = 64;
    }
    return _searchImageButton;
}

- (UIView *)maskInputView {
    if (!_maskInputView) {
        _maskInputView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE != 3) {
            _maskInputView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
        
//        @weakify(self);
//        [_maskInputView addTapGestureWithComplete:^(UIView * _Nonnull view) {
//            @strongify(self);
//            if (self.inputCompletionHandler) {
//                self.inputCompletionHandler();
//            }
//        }];
    }
    return _maskInputView;
}

- (UIImageView *)searchView {
    if (!_searchView) {
        _searchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_gray"]];
    }
    return _searchView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        if (APP_TYPE != 3) {
            _inputField.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
        
        _inputField.delegate = self;
        _inputField.font = [UIFont systemFontOfSize:14];
//        _inputField.textColor = OSSVThemesColors.col_999999;
        _inputField.textColor = [OSSVThemesColors col_B2B2B2];
        _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputField.placeholder = STLLocalizedString_(@"search", nil);
        _inputField.textAlignment = NSTextAlignmentLeft;
        _inputField.hidden = YES;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _inputField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _inputField;
}

//文字滚动
- (SDCycleScrollView *)searchScroll {
    if (!_searchScroll) {
        _searchScroll = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@""]];
        _searchScroll.onlyDisplayText = YES;
        _searchScroll.backgroundColor = [UIColor clearColor];
        _searchScroll.autoScrollTimeInterval = 2;
        _searchScroll.titleLabelHeight = 20;
        _searchScroll.titleLabelTextColor = OSSVThemesColors.col_B2B2B2;
        _searchScroll.titleLabelTextFont  = [UIFont systemFontOfSize:14];
        _searchScroll.titleLabelBackgroundColor = [UIColor clearColor];
        _searchScroll.scrollDirection = UICollectionViewScrollDirectionVertical;
        [_searchScroll disableScrollGesture];
    }
    return _searchScroll;
}

- (NSMutableArray *)titleGroupArray {
    if (!_titleGroupArray) {
        _titleGroupArray = [NSMutableArray array];
    }
    return _titleGroupArray;
}

- (void)setHotWordsArray:(NSArray *)hotWordsArray {
    _hotWordsArray = hotWordsArray;
    [self.titleGroupArray removeAllObjects];
    NSArray *subArray = [NSArray array];
    if (self.hotWordsArray.count > 3) {
       subArray = [self.hotWordsArray  subarrayWithRange:NSMakeRange(0, 3)];  //截取3个数据
    } else {
        subArray = self.hotWordsArray;
    }

    if (subArray.count) {
        for (OSSVHotsSearchWordsModel *model in subArray) {
            [self.titleGroupArray addObject:STLToString(model.word)];
        }
        self.searchScroll.titlesGroup = self.titleGroupArray;
    } else {
        self.inputField.hidden = NO;
        self.inputField.userInteractionEnabled = YES;
        @weakify(self)
        [self.inputField whenTapped:^{
            @strongify(self)
            if (self.inputCompletionHandler) {
                self.inputCompletionHandler();
            }
        }];
    }
}

#pragma mark ---SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
    NSString *indexStr = @"";
    if (self.titleGroupArray.count) {
        indexStr = self.titleGroupArray[index];
        NSLog(@"点击的文字：%@", indexStr);
    } else {
        indexStr = @"";
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textClick:)]) {
        [self.delegate textClick:indexStr];
    }
}
@end
