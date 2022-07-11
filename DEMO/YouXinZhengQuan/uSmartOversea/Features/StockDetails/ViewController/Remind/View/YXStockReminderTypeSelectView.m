//
//  YXStockReminderTypeSelectView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderTypeSelectView.h"
#import "uSmartOversea-Swift.h"
#import "NSString+YYAdd.h"
#import "YXRemindTool.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockReminderInputView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation YXStockReminderInputView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = QMUITheme.foregroundColor;
    
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(250);
    }];
    
    [self addSubview:self.unitLabel];
    self.unitLabel.frame = CGRectMake(16, 0, 50, 56);
    
    @weakify(self);
    [self.textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if (x.length > 0 && self.unitLabel.text.length > 0) {
            self.unitLabel.hidden = NO;
            CGSize size = [x sizeForFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] size:CGSizeMake(MAXFLOAT, 40) mode:NSLineBreakByTruncatingTail];
            self.unitLabel.mj_x = 16 + size.width + 4;
        } else {
            self.unitLabel.hidden = YES;
        }
    }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self.textField textField:textField shouldChangeCharactersIn:range replacementString:string];
}

- (void)setType:(YXReminderType)type {
    _type = type;
    self.unitLabel.text = [YXRemindTool getUnitStrWithType:type];
    self.unitLabel.hidden = self.unitLabel.text.length > 0;
    self.textField.placeholder = [YXRemindTool getPlaceHoldStrWithType:type];
}


- (YXTextField *)textField{
    if (!_textField) {
        _textField = [[YXTextField alloc] init];
        _textField.textColor = [QMUITheme textColorLevel1];
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        _textField.banAction = YES;
        _textField.inputType = InputTypeMoney;
        _textField.integerBitCount = 8;
        _textField.decimalBitCount = 3;
        _textField.delegate = self;
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"remind_input_value"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [QMUITheme textColorLevel4]}];
    }
    return _textField;
}


- (UILabel *)unitLabel {
    if (_unitLabel == nil) {
        _unitLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
        
    }
    return _unitLabel;
}

@end


@implementation YXStockReminderTypeSelectView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    
//    self.iconImageView = [[UIImageView alloc] init];
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    UIImageView *arrowView = [[UIImageView alloc] init];
    arrowView.image = [UIImage imageNamed:@"remind_arrow_icon"];
    
    self.clickBtn = [[UIButton alloc] init];
    
    
//    [self addSubview:self.iconImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:arrowView];
    [self addSubview:self.clickBtn];
    
//    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(12);
//        make.centerY.equalTo(self);
//        make.width.height.mas_equalTo(20);
//    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self);
    }];
    
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-12);
        make.centerY.equalTo(self);
//        make.width.height.mas_equalTo(15);
    }];
    
    [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}

@end
