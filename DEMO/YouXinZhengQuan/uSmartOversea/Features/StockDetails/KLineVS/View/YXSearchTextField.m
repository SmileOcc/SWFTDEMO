//
//  YXSearchTextField.m
//  YouXinZhengQuan
//
//  Created by rrd on 2018/7/30.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXSearchTextField.h"
#import <Masonry/Masonry.h>
#import "UIView+Borders.h"
#import "uSmartOversea-Swift.h"

@interface YXSearchTextField () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UIButton *clearButton;


@end

@implementation YXSearchTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        [self initializeViews];
    }
    return self;
}

- (void)dealloc
{
    self.textField.delegate = nil;
}

- (void)initializeViews {
    self.backgroundColor = [[QMUITheme textColorLevel2] colorWithAlphaComponent:0.05];
    [self makeCorners:6];
    
    [self addSubview:self.iconImg];
    [self addSubview:self.textField];
    [self addSubview:self.clearButton];
    
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.height.equalTo(self);
    }];
    
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.top.height.equalTo(self);
        make.right.equalTo(self.clearButton).offset(-10);
    }];
    
    RAC(self, text) = [[RACObserve(self.textField, text) merge: self.textField.rac_textSignal] takeUntil:self.rac_willDeallocSignal];
    
    id (^map)(NSString *value) = ^ id (NSString *value) {
        if (value.isNotEmpty) {
            return @NO;
        } else {
            return @YES;
        }
    };
    
    self.textField.delegate = self;
    
    RACSignal *hiddenSignal = [[RACSignal merge:@[[self.textField.rac_textSignal map:map], [RACObserve(self.textField, text) map:map]]] takeUntil:self.rac_willDeallocSignal];
    RAC(self.clearButton, hidden) = hiddenSignal;
}

- (void)showImportButton {
    [self addSubview:self.importButton];
    [self.importButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.height.equalTo(self);
    }];
    RAC(self.importButton, hidden) = RACObserve(self.clearButton, hidden).not;
}

- (void)clearBtnAction{
    _textField.text = @"";
}

#pragma mark - getter
- (UIButton *)importButton{
    if (_importButton == nil) {
        _importButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_importButton setImage:[UIImage imageNamed:@"import_stock"] forState:UIControlStateNormal];
    }
    return _importButton;
}

- (UIImageView *)iconImg {
    if (_iconImg == nil) {
        _iconImg = [[UIImageView alloc] initWithImage:YX_IMAGE_NAMED(@"yx_v2_big_search")];
    }
    return _iconImg;
}

- (UIButton *)clearButton {
    if (_clearButton == nil) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"stockSearch_closed"] target:self action:@selector(clearBtnAction)];
    }
    return _clearButton;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = [YXLanguageUtility kLangWithKey:@"search_detail_placeholder"];
        BeginIgnoreUIKVCAccessProhibited
        [_textField setValue:QMUITheme.textColorLevel3 forKeyPath:@"_placeholderLabel.textColor"];
        EndIgnoreUIKVCAccessProhibited
        _textField.tintColor = [QMUITheme textColorLevel1];
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.clearButtonMode = UITextFieldViewModeNever;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = [QMUITheme textColorLevel1];        
    }
    return _textField;
}
@end
