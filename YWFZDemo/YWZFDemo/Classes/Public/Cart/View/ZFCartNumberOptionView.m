//
//  ZFCartNumberOptionView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartNumberOptionView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFCartNumberOptionView () <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UIButton          *increaseButton;
@property (nonatomic, strong) UITextField       *countTextField;
@property (nonatomic, strong) UIButton          *decreaseButton;
@end

@implementation ZFCartNumberOptionView

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.decreaseButton];
    [self addSubview:self.countTextField];
    [self addSubview:self.increaseButton];
}

- (void)zfAutoLayoutView {
    [self.decreaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self);
        make.width.mas_equalTo(@35);
    }];
    
    [self.countTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self.decreaseButton.mas_trailing).offset(2);
        make.width.mas_equalTo(@40);
    }];
    
    [self.increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.width.mas_equalTo(@(35));
    }];
}

#pragma mark - action methods

//设置【减】按钮颜色
- (void)updateDecreaseButtonState:(BOOL)normal{
    UIImage *image = normal ? [UIImage imageNamed:@"cart_decrease_normal"] : [UIImage imageNamed:@"cart_delete_goods"];
    [self.decreaseButton setImage:image forState:UIControlStateNormal];
    [self.decreaseButton setImage:image forState:UIControlStateHighlighted];
}

- (void)decreaseButtonActoin:(UIButton *)sender {
    NSInteger count = self.goodsNumber - 1;
    if (count >= 1) {
        [self updateDecreaseButtonState:YES];
        
    } else {//当减后数量为0时，点击不响应事件
        [self updateDecreaseButtonState:NO];
//        return;
    }
    [sender.layer addAnimation:[self createOptionAnimation] forKey:@""];
    if (self.cartGoodsCountChangeCompletionHandler) {
        self.cartGoodsCountChangeCompletionHandler(count);
    }
}

- (void)increaseButtonAction:(UIButton *)sender {
    [sender.layer addAnimation:[self createOptionAnimation] forKey:@""];
    if (self.cartGoodsCountChangeCompletionHandler) {
        self.cartGoodsCountChangeCompletionHandler(self.goodsNumber + 1);
    }
}

- (CAKeyframeAnimation *)createOptionAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.1), @(1.0), @(1.5)];
    animation.keyTimes = @[@(0.0), @(0.5), @(0.8), @(1.0)];
    animation.calculationMode = kCAAnimationLinear;
    return animation;
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) return YES;
    if (textField.text.length > 2){
        return NO;
    }else{
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.text integerValue] > self.maxGoodsNumber) {
        self.goodsNumber = self.maxGoodsNumber;
    } else if ([textField.text integerValue] <= 0) {
        self.goodsNumber = 1;
    } else {
        self.goodsNumber = [textField.text integerValue];
    }
    if (self.cartGoodsCountChangeCompletionHandler) {
        self.cartGoodsCountChangeCompletionHandler(self.goodsNumber);
    }
}

#pragma mark - setter/getter

- (void)setGoodsNumber:(NSInteger)goodsNumber {
    if (goodsNumber > self.maxGoodsNumber) {
        return ;
    }
    _goodsNumber = goodsNumber;
    self.countTextField.text = [NSString stringWithFormat:@"%lu", _goodsNumber];
    [self updateDecreaseButtonState:_goodsNumber > 1];
}

- (void)setMaxGoodsNumber:(NSInteger)maxGoodsNumber {
    _maxGoodsNumber = maxGoodsNumber;
    self.countTextField.enabled = _maxGoodsNumber > 1;
    self.increaseButton.enabled = _maxGoodsNumber > 1;
}

- (UIButton *)increaseButton {
    if (!_increaseButton) {
        _increaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _increaseButton.backgroundColor = [UIColor clearColor];
        [_increaseButton addTarget:self action:@selector(increaseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_increaseButton setImage:[UIImage imageNamed:@"cart_increase_normal"] forState:UIControlStateNormal];
        [_increaseButton setImage:[UIImage imageNamed:@"cart_increase_disabled"] forState:UIControlStateDisabled];
    }
    return _increaseButton;
}

- (UITextField *)countTextField {
    if (!_countTextField) {
        _countTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _countTextField.keyboardType = UIKeyboardTypeNumberPad;
        _countTextField.returnKeyType = UIReturnKeyDone;
        _countTextField.font = [UIFont systemFontOfSize:14.0];
        _countTextField.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _countTextField.textAlignment = NSTextAlignmentCenter;
        _countTextField.delegate = self;
    }
    return _countTextField;
}

- (UIButton *)decreaseButton {
    if (!_decreaseButton) {
        _decreaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseButton.backgroundColor = [UIColor clearColor];
        [_decreaseButton addTarget:self action:@selector(decreaseButtonActoin:) forControlEvents:UIControlEventTouchUpInside];
        [_decreaseButton setImage:[UIImage imageNamed:@"cart_decrease_normal"] forState:UIControlStateNormal];
        [_decreaseButton setImage:[UIImage imageNamed:@"cart_decrease_disabled"] forState:UIControlStateDisabled];
    }
    return _decreaseButton;
}
@end
