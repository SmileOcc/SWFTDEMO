//
//  YXPasswordResetView.m
//  YXPasswordSetInputView
//
//  Created by Kelvin on 2018/8/16.
//  Copyright © 2018年 Kelvin. All rights reserved.
//

#import "YXPasswordResetView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXPasswordResetView () <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *textFieldArr; //labArr
@property (nonatomic, strong) NSMutableArray *circularArr;//圆点
@property (nonatomic, strong) NSMutableArray *borderArr;//边框
@property (nonatomic, strong) NSMutableArray *textArr; //text
@property (nonatomic, assign) CGFloat width; // 长
@property (nonatomic, assign) CGFloat viewWidth; //界面宽
@property (nonatomic, strong) NSTimer *timer; //圆点显示定时器
@property (nonatomic, assign) BOOL isDel; //是否是删除text
@property (nonatomic, strong) YXTextField *textField;

@end

@implementation YXPasswordResetView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithGridWidth:(CGFloat)width viewWidth:(float)viewWidth{
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.width = width;
        self.viewWidth = viewWidth;
        [self initUI];
    }
    return self;
}

#pragma mark- UI
- (void)initUI{
    
    self.textFieldEnable = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesture];
    self.textField = [[YXTextField alloc] init];
    self.textField.banAction = YES;
    [self addSubview:self.textField];
    self.textField.delegate = self;
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    //    self.textField.keyboardDistanceFromTextField = 150;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.tintColor = [UIColor clearColor];
    self.textField.textColor = [UIColor clearColor];
    for (int x = 0; x < 6; x ++) {
        
        UIView *view = [[UIView alloc]init];
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = 6;
        view.layer.masksToBounds = YES;
        
        [self.borderArr addObject:view];
        [self addSubview:view];
        
        UILabel *textFieldLabel  =  [self createTextLabel];
        [self.textFieldArr addObject:textFieldLabel];
        [self addSubview:textFieldLabel];
        
        float space = (self.viewWidth - self.width*6)/5;
        [textFieldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.width-3);
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(14 + (self.width+space)*x);
        }];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.width);
            make.center.mas_equalTo(textFieldLabel);
        }];
        
        UILabel *circularLab = [[UILabel alloc] init];
        circularLab.font =  [UIFont fontWithName:@"DINPro-Regular" size:30];
        circularLab.hidden = YES;
        circularLab.layer.cornerRadius = 5;
        circularLab.clipsToBounds = true;
        [self addSubview:circularLab];
        [circularLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(textFieldLabel);
            make.centerY.equalTo(textFieldLabel);
            make.width.height.mas_equalTo(10);
        }];
        [self.circularArr addObject:circularLab];
    }
}

#pragma mark- 懒加载
- (UILabel *)createTextLabel{
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont fontWithName:@"DINPro-Regular" size:30];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.layer.borderWidth = 1;
    textLabel.layer.cornerRadius = 6;
    textLabel.layer.borderColor = [UIColor clearColor].CGColor;
    textLabel.layer.masksToBounds = YES;
    textLabel.userInteractionEnabled = YES;
    return textLabel;
}

- (void)tapAction{
    [self.textField becomeFirstResponder];
}

- (NSMutableArray *)textFieldArr{
    
    if (!_textFieldArr) {
        _textFieldArr = [NSMutableArray array];
    }
    return _textFieldArr;
}

- (NSMutableArray *)borderArr{
    if (!_borderArr) {
        _borderArr = [NSMutableArray array];
    }
    return _borderArr;
}

- (NSMutableArray *)circularArr{
    if (!_circularArr) {
        _circularArr = [NSMutableArray array];
    }
    return _circularArr;
}

- (NSMutableArray *)textArr{
    
    if (!_textArr) {
        _textArr = [NSMutableArray array];
    }
    return _textArr;
    
}

#pragma mark- set方法
- (void)setNormalColor:(UIColor *)normalColor{
    
    _normalColor = normalColor;
    for (int x = 0; x < self.borderArr.count; x ++) {
        UIView *v = self.borderArr[x];
        if (x!=0) {
            v.layer.borderColor = normalColor.CGColor;
        }
    }
}

- (void)setSeletedColor:(UIColor *)seletedColor {
    _seletedColor = seletedColor;
    UIView *v = self.borderArr[0];
    v.layer.borderColor = seletedColor.CGColor;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    for (int x = 0; x < self.textFieldArr.count; x ++) {
        
        UILabel *label = self.textFieldArr[x];
        label.textColor = textColor;
        
        UILabel *v = self.circularArr[x];
        v.backgroundColor = textColor;
    }
}

- (void)setTextFont:(UIFont *)textFont{
    _textFont = textFont;
    for (int x = 0; x < self.textFieldArr.count; x ++) {
        UILabel *label = self.textFieldArr[x];
        label.font = textFont;
    }
}

#pragma mark- delegate
- (void)textFieldDidChange:(UITextField *)textField{
    
    if (self.textArr.count > textField.text.length) {
        self.isDel = YES;
    }else{
        self.isDel = NO;
    }
    [self.textArr removeAllObjects];
    for (int i = 0; i < textField.text.length; i ++) {
        NSRange range;
        range.location = i;
        range.length = 1;
        NSString *tempString = [textField.text substringWithRange:range];
        [self.textArr addObject:tempString];
    }
    
    for (int x = 0; x < self.textFieldArr.count; x ++) {
        UILabel *label = self.textFieldArr[x];
        UIView *borderView =  self.borderArr[x];
        if (x < self.textArr.count) {
            label.text = self.textArr[x];
        }else{
            label.text = nil;
        }
        
        if (x == self.textArr.count){
            borderView.layer.borderColor = self.seletedColor.CGColor;
        }else {
            borderView.layer.borderColor = self.normalColor.CGColor;
        }
        
    }
    
    if (self.timer) {
        [self.timer invalidate];
    }
    
    [self setCircular];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (!self.textFieldEnable) {
        return NO;
    }
    
    if (string.length == 0) {
        return YES;
    }
    else if (textField.text.length >= 6) {
        textField.text = [textField.text substringToIndex:6];
        return NO;
    }
    return YES;
}


#pragma mark- other
//timerAction
- (void)timerAction{
    
    for (int i = 0; self.textArr.count > i; i++) {
        UILabel *v = self.circularArr[i];
        UILabel *lab = self.textFieldArr[i];
        v.hidden = NO;
        lab.hidden = YES;
    }
    
}

//清除输入内容
- (void)clearText{
    
    [self.textArr removeAllObjects];
    self.textField.text = @"";
    for (int i=0; i<6; i++) {
        
        UILabel *v = self.circularArr[i];
        UILabel *lab = self.textFieldArr[i];
        UIView *b = self.borderArr[i];
        if (i == 0) {
            b.layer.borderColor = self.seletedColor.CGColor;
        }else {
            b.layer.borderColor = self.normalColor.CGColor;
        }
        v.hidden = YES;
        lab.hidden = NO;
        lab.text = @"";
    }
    
}

//调用timer前控制当前lab 的前后lab 状态变化
- (void)setCircular{
    
    if (!self.isDel) {
        
        UILabel *v = self.circularArr[self.textArr.count-1];
        UILabel *lab = self.textFieldArr[self.textArr.count-1];
        v.hidden = YES;
        lab.hidden = NO;
        
    }
    
    if (self.textArr.count > 1) {
        UILabel *v = self.circularArr[self.textArr.count-2];
        UILabel *lab = self.textFieldArr[self.textArr.count-2];
        v.hidden = NO;
        lab.hidden = YES;
    }
    
    if (self.textArr.count < 6) {
        UILabel *v = self.circularArr[self.textArr.count];
        UILabel *lab = self.textFieldArr[self.textArr.count ];
        v.hidden = YES;
        lab.hidden = NO;
    }
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    self.textField.delegate = nil;
}

@end
