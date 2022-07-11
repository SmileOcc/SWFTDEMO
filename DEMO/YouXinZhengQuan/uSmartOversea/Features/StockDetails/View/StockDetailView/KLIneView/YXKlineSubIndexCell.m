//
//  YXKlineSubIndexCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKlineSubIndexCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXKlineSubIndexCell ()<UITextFieldDelegate>

@property (nonatomic, strong) YXExpandAreaButton *minusButton;
@property (nonatomic, strong) YXExpandAreaButton *plusButton;

@property (nonatomic, strong) YXExpandAreaButton *selectButton;
@property (nonatomic, strong) UITextField *maText;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) NSInteger min;
@property (nonatomic, assign) NSInteger max;

@end

@implementation YXKlineSubIndexCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {

    self.min = 1;
    self.max = 250;
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.selectButton];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.minusButton];
    [self.contentView addSubview:self.plusButton];
    [self.contentView addSubview:self.maText];
     
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.height.width.mas_equalTo(16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(42);
    }];
    
    [self.minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-124);
        make.width.height.mas_equalTo(28);
    }];
    
    [self.plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.equalTo(self.contentView).offset(-16);
        make.width.height.mas_equalTo(28);
    }];
    
    [self.maText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.minusButton.mas_right);
        make.right.mas_equalTo(self.plusButton.mas_left);
    }];
    
    //ma: 1-250之间的整数
    [self.maText addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];

}

- (void)textField1TextChange:(UITextField *)textField {

    [self verifyValue];
}

- (void)verifyValue {

    if (self.maText.text.length == 0) {
        [QMUITips showWithText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"stock_setting_input_tip"], self.min, self.max]];
    } else {
        if (self.maText.text.doubleValue > self.max) {
            [QMUITips showWithText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"stock_setting_input_tip"], self.min, self.max]];
            self.maText.text = [NSString stringWithFormat:@"%zd",self.max];
        } else if (self.maText.text.doubleValue < self.min) {
            [QMUITips showWithText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"stock_setting_input_tip"], self.min, self.max]];
            self.maText.text = [NSString stringWithFormat:@"%zd",self.min];
        }
        self.model.cycle = self.maText.text.integerValue;
        if (self.changeCycleCallBack) {
            self.changeCycleCallBack();
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string containsString:@"."]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - lazy load
- (YXExpandAreaButton *)selectButton{
    
    if (!_selectButton) {
        _selectButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"noSelectStockBg"] target:self action:@selector(selectButtonEvent:)];
        [_selectButton setTitle:@"" forState: UIControlStateNormal];
        [_selectButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        [_selectButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        [_selectButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [_selectButton setImage:[UIImage imageNamed:@"selectStockBg"] forState:UIControlStateSelected];
    }
    return _selectButton;
    
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
    }
    return _titleLabel;
}

- (void)selectButtonEvent:(UIButton *)button{
    
    button.selected = !button.selected;
    self.model.isHidden = !button.selected;
}

- (void)setModel:(YXKlineSubConfigModel *)model {
    _model = model;
    if (model.type == 0) {
        self.selectButton.hidden = YES;
        self.plusButton.hidden = NO;
        self.minusButton.hidden = NO;
        self.maText.hidden = NO;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(16);
        }];
    } else if (model.type == 1) {
        self.selectButton.hidden = NO;
        self.plusButton.hidden = NO;
        self.minusButton.hidden = NO;
        self.maText.hidden = NO;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(42);
        }];
    } else {
        self.selectButton.hidden = NO;
        self.plusButton.hidden = YES;
        self.minusButton.hidden = YES;
        self.maText.hidden = YES;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(42);
        }];
    }
    self.titleLabel.text = model.title;
    self.maText.text = [NSString stringWithFormat:@"%zd",model.cycle];
    self.maText.placeholder = model.placeholder;
    self.selectButton.selected = !model.isHidden;
    
    if (model.placeholder.length > 0) {
        NSArray <NSString *>*arr = [model.placeholder componentsSeparatedByString:@"～"];
        if (arr.count == 2) {
            self.min = arr[0].integerValue;
            self.max = arr[1].integerValue;
        }
    }
}

- (UIButton *)minusButton{
    
    if (!_minusButton) {
        _minusButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom title:@"-" font:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium] titleColor:[QMUITheme textColorLevel3] target:self action:nil];
        _minusButton.backgroundColor = QMUITheme.blockColor;
        _minusButton.layer.cornerRadius = 2;
        _minusButton.layer.masksToBounds = YES;
        @weakify(self);
        [[_minusButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSInteger textInteg = self.maText.text.integerValue;
            self.maText.text = [NSString stringWithFormat:@"%ld", textInteg - 1];
            [self verifyValue];
        }];
    }
    return _minusButton;
    
}

- (UIButton *)plusButton{
    
    if (!_plusButton) {
        _plusButton = [YXExpandAreaButton buttonWithType:UIButtonTypeCustom title:@"+" font:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium] titleColor:[QMUITheme textColorLevel3] target:self action:nil];
        _plusButton.backgroundColor = QMUITheme.blockColor;
        _plusButton.layer.cornerRadius = 2;
        _plusButton.layer.masksToBounds = YES;
        @weakify(self);
        [[_plusButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSInteger textInteg = self.maText.text.integerValue;
            self.maText.text = [NSString stringWithFormat:@"%ld", textInteg + 1];
            [self verifyValue];
        }];
    }
    return _plusButton;
    
}

- (UITextField *)maText{
    
    if (!_maText) {
        _maText = [[UITextField alloc] init];
        _maText.textColor = [QMUITheme textColorLevel1];
        _maText.textAlignment = NSTextAlignmentCenter;
        _maText.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _maText.keyboardType = UIKeyboardTypeDecimalPad;
        _maText.delegate = self;
    }
    return _maText;
    
}


@end
