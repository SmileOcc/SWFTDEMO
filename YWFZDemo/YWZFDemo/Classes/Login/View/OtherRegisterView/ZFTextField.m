//
//  ZFTextField.m
//  ZZZZZ
//
//  Created by YW on 29/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTextField.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "ZFNotificationDefiner.h"

static const CGFloat kLineWidth             = 1;
static const CGFloat kFloatingLabelYPadding = 4;
static const CGFloat kFloatingLabelShowAnimationDuration = 0.3f;

@interface ZFTextField ()
@property (nonatomic, strong) UILabel    *placeholderAnimationLabel;
@property (nonatomic, strong) UILabel    *errorTipLabel;
@property (nonatomic, strong) UIView     *lineView;
@property (nonatomic, copy)   NSString   *placeholderText;
@property (nonatomic, strong) CALayer    *lineLayer; //填充线
@property (nonatomic, assign) BOOL       moved; //只移动一次
@property (nonatomic, assign) BOOL       isShowErrorTip; // 只显示一次
@end

@implementation ZFTextField
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tintColor = [UIColor darkGrayColor];  // 光标颜色
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.keyboardType = UIKeyboardTypeDefault;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.clipsToBounds = NO;

        self.placeholderNormalStateColor = ZFCOLOR(212, 212, 212, 1);
        self.placeholderSelectStateColor = ZFCOLOR(212, 212, 212, 1);
        self.floatingLabelXPadding = 0;
        self.isSecure = NO;
        self.animationFont = [UIFont fontWithName:self.font.fontName size:roundf(self.font.pointSize*0.75)];
        
        [self addSubview:self.placeholderAnimationLabel];
        [self addSubview:self.errorTipLabel];
        [self addSubview:self.lineView];
        [self.lineView.layer addSublayer:self.lineLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEditing:) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEditing:) name:kShowPlaceholderAnimationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat placeHolder_X = [SystemConfigUtils isRightToLeftShow] ? 0 : self.floatingLabelXPadding;
    self.placeholderAnimationLabel.frame = CGRectMake(placeHolder_X, 0, CGRectGetWidth(self.frame) - self.floatingLabelXPadding, CGRectGetHeight(self.frame)-kLineWidth);
    self.lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kLineWidth, CGRectGetWidth(self.frame), kLineWidth);
    self.errorTipLabel.frame = CGRectMake(CGRectGetMinX(self.placeholderAnimationLabel.frame), CGRectGetMaxY(self.placeholderAnimationLabel.frame) + 1, CGRectGetWidth(self.frame) - self.floatingLabelXPadding, 22);
    if (self.clearImage) {
        UIButton *button = [self valueForKey:@"_clearButton"];
        [button setImage:self.clearImage forState:UIControlStateNormal];
    }
}

// 改变输入文字位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat start_X = [SystemConfigUtils isRightToLeftShow] ? bounds.origin.x + self.leftImage.size.width + 5: bounds.origin.x + self.floatingLabelXPadding;
    CGFloat width = [SystemConfigUtils isRightToLeftShow] ? bounds.size.width - self.floatingLabelXPadding - self.leftImage.size.width - 5 : bounds.size.width - self.floatingLabelXPadding - 45;
    
    CGRect inset = CGRectMake(start_X, bounds.origin.y, width, bounds.size.height);
    return inset;
}

// 改变光标位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat start_X = [SystemConfigUtils isRightToLeftShow] ? bounds.origin.x + self.leftImage.size.width + 5 : bounds.origin.x + self.floatingLabelXPadding;
    CGFloat width = [SystemConfigUtils isRightToLeftShow] ? bounds.size.width - self.floatingLabelXPadding - self.leftImage.size.width - 5 : bounds.size.width - self.floatingLabelXPadding - 45;
    
    CGRect inset = CGRectMake(start_X, bounds.origin.y, width, bounds.size.height);
    return inset;
}

// 改变clear按钮位置
- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    if (self.rightButton) {
        rect.origin.x = [SystemConfigUtils isRightToLeftShow] ? CGRectGetWidth(self.rightButton.frame) + 8 : CGRectGetWidth(self.frame) - rect.size.width - CGRectGetWidth(self.rightButton.frame) - 8;
    }else{
        rect.origin.x = [SystemConfigUtils isRightToLeftShow] ? 5: CGRectGetWidth(self.frame) - rect.size.width - 5;
    }
    return CGRectIntegral(rect);
}

#pragma mark - UIKeyInput
- (void)deleteBackward {
    if ([self.text length] == 0) {
        if ([self.zf_delegate respondsToSelector:@selector(zfTextFieldDeleteBackward:)]) {
            [self.zf_delegate zfTextFieldDeleteBackward:self];
        }
    }
    [super deleteBackward];
}

#pragma mark - Public method
- (void)resetAnimation {
    CGFloat y = self.placeholderAnimationLabel.center.y;
    CGFloat x = self.placeholderAnimationLabel.center.x;
    [self backAnimation:x y:y];
    [self hideErrorTipLabel];
}

- (void)showErrorTipLabel:(BOOL)isShowErrorTip {
    self.isShowErrorTip = isShowErrorTip;
    self.errorTipLabel.hidden = NO;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @(0);
    opacity.toValue = @(1);

    CABasicAnimation *positionY = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionY.fromValue =  @(CGRectGetMidY(self.errorTipLabel.frame) + CGRectGetHeight(self.errorTipLabel.frame) + 2);
    positionY.toValue =  @(CGRectGetMidY(self.errorTipLabel.frame));
    
    CAAnimationGroup *anigroup = [CAAnimationGroup animation];
    anigroup.animations = @[opacity,positionY];
    anigroup.duration = 0.25;
    anigroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anigroup.beginTime = CACurrentMediaTime();
    anigroup.fillMode = kCAFillModeForwards;
    anigroup.removedOnCompletion = NO;
    [self.errorTipLabel.layer addAnimation:anigroup forKey:@"anigroup"];
    
    CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
    bounds.fromValue = [NSValue valueWithCGRect:CGRectMake(0,0, 0, kLineWidth)];
    bounds.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), kLineWidth)];
    bounds.duration = kFloatingLabelShowAnimationDuration;
    bounds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bounds.beginTime = CACurrentMediaTime();
    bounds.fillMode = kCAFillModeForwards;
    bounds.removedOnCompletion = NO;
    [self.lineLayer addAnimation:bounds forKey:@"boundsShow"];
    
    CABasicAnimation *backgroundColor = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    backgroundColor.fromValue = (id)self.placeholderSelectStateColor.CGColor;
    backgroundColor.toValue = (id)[UIColor orangeColor].CGColor;
    backgroundColor.duration = 0.3;
    backgroundColor.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    backgroundColor.beginTime = CACurrentMediaTime();
    backgroundColor.fillMode = kCAFillModeForwards;
    backgroundColor.removedOnCompletion = NO;
    [self.lineLayer addAnimation:backgroundColor forKey:@"backgroundColor"];
}

- (void)hidenErrorTipLine {
    [self.lineLayer removeAllAnimations];
    [self.errorTipLabel.layer removeAllAnimations];
}

- (void)resetMoved:(BOOL)isMoved {
    _moved = isMoved;
}
#pragma mark - Private method
- (void)hideErrorTipLabel {
    CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
    bounds.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), kLineWidth)];
    bounds.toValue = [NSValue valueWithCGRect:CGRectMake(0,0, 0, kLineWidth)];
    bounds.duration = kFloatingLabelShowAnimationDuration;
    bounds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bounds.beginTime = CACurrentMediaTime();
    bounds.fillMode = kCAFillModeForwards;
    bounds.removedOnCompletion = NO;
    [self.lineLayer addAnimation:bounds forKey:@"boundsHide"];
    
    [UIView animateWithDuration:0.25
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.lineLayer removeAllAnimations];
                         [self.errorTipLabel.layer removeAllAnimations];
                     }
                     completion:nil];
    self.isShowErrorTip = NO;
}

#pragma mark - Notification action
- (void)beginEditing:(NSNotification *)center {
//    if (![self isEqual:center.object]) {
//        return;
//    }
    if (!self.isShowErrorTip) return;
    [self hideErrorTipLabel];
}

- (void)changeEditing:(NSNotification *)center {
//    if (![self isEqual:center.object]) {
//        return;
//    }
    [self showPlaceholderAnimation];
}

- (void)showPlaceholderAnimation {
    CGFloat y = self.placeholderAnimationLabel.center.y -2;
    CGFloat x = self.placeholderAnimationLabel.center.x;
    if((self.text.length != 0 && !_moved) || self.isSecure){
        [self moveAnimation:x y:y];
    }else if(self.text.length == 0 && _moved){
        [self backAnimation:x y:y];
    }
}

- (void)moveAnimation:(CGFloat)x y:(CGFloat)y {
    _moved = YES;
    self.isSecure = NO;
    [self.placeholderAnimationLabel.layer removeAllAnimations];
    [self.lineView.layer removeAllAnimations];
    
    void (^showBlock)(void) = ^{
        self.placeholderAnimationLabel.font = self.animationFont;
        self.placeholderAnimationLabel.textColor = self.placeholderSelectStateColor;
    };

    [UIView animateWithDuration:kFloatingLabelShowAnimationDuration
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    CGFloat to_X = [SystemConfigUtils isRightToLeftShow] ? x + self.floatingLabelXPadding : x - self.floatingLabelXPadding;
    position.toValue = [NSValue valueWithCGPoint:CGPointMake(to_X, y - (_placeholderAnimationLabel.frame.size.height/2 + kFloatingLabelYPadding))];
    position.duration = kFloatingLabelShowAnimationDuration;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.beginTime = CACurrentMediaTime();
    position.fillMode = kCAFillModeForwards;
    position.removedOnCompletion = NO;
    [self.placeholderAnimationLabel.layer addAnimation:position forKey:@"position"];

    CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
    bounds.fromValue = [NSValue valueWithCGRect:CGRectMake(0 ,0, 0, kLineWidth)];
    bounds.toValue = [NSValue valueWithCGRect:CGRectMake(0 , 0, CGRectGetWidth(self.frame), kLineWidth)];
    bounds.duration = kFloatingLabelShowAnimationDuration;
    bounds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bounds.beginTime = CACurrentMediaTime();
    bounds.fillMode = kCAFillModeForwards;
    bounds.removedOnCompletion = NO;
    [self.lineLayer addAnimation:bounds forKey:@"boundsShow"];
}

- (void)backAnimation:(CGFloat)x y:(CGFloat)y {
    _moved = NO;
    [self.placeholderAnimationLabel.layer removeAllAnimations];
    [self.lineView.layer removeAllAnimations];
    
    void (^showBlock)(void) = ^{
        self.placeholderAnimationLabel.font = self.font;
        self.placeholderAnimationLabel.textColor = self.placeholderNormalStateColor;
    };
    
    [UIView animateWithDuration:kFloatingLabelShowAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];

    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    CGFloat from_X = [SystemConfigUtils isRightToLeftShow] ? x + self.floatingLabelXPadding : x - self.floatingLabelXPadding;
    position.fromValue = [NSValue valueWithCGPoint:CGPointMake(from_X, y - (CGRectGetHeight(self.placeholderAnimationLabel.frame)/2 + kFloatingLabelYPadding))];
    position.toValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    position.duration = kFloatingLabelShowAnimationDuration;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    position.beginTime = CACurrentMediaTime();
    position.fillMode = kCAFillModeForwards;
    position.removedOnCompletion = NO;
    [self.placeholderAnimationLabel.layer addAnimation:position forKey:@"position"];
    
    CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
    bounds.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), kLineWidth)];
    bounds.toValue = [NSValue valueWithCGRect:CGRectMake(0,0, 0, kLineWidth)];
    bounds.duration = kFloatingLabelShowAnimationDuration;
    bounds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bounds.beginTime = CACurrentMediaTime();
    bounds.fillMode = kCAFillModeForwards;
    bounds.removedOnCompletion = NO;
    [self.lineLayer addAnimation:bounds forKey:@"boundsHide"];
}

#pragma mark - Setter
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderAnimationLabel.font = self.font;
    [self invalidateIntrinsicContentSize];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholderText = placeholder;
    self.placeholderAnimationLabel.text = placeholder;
}

- (void)setPlaceholderNormalStateColor:(UIColor *)placeholderNormalStateColor{
    _placeholderNormalStateColor = placeholderNormalStateColor;
}

- (void)setPlaceholderSelectStateColor:(UIColor *)placeholderSelectStateColor{
    _placeholderSelectStateColor = placeholderSelectStateColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderAnimationLabel.textColor = placeholderColor;
}

- (void)setCursorColor:(UIColor *)cursorColor{
    self.tintColor = cursorColor;
}

-(void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.lineLayer.backgroundColor = lineColor.CGColor;
}

- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    if (!leftImage) return;
    self.floatingLabelXPadding += leftImage.size.width + 5;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:leftImage];
    imgView.contentMode = UIViewContentModeCenter;
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.semanticContentAttribute = [SystemConfigUtils isRightToLeftLanguage] ? UISemanticContentAttributeForceLeftToRight : UISemanticContentAttributeForceRightToLeft;
        self.rightView = imgView;
        self.rightViewMode = UITextFieldViewModeAlways;
    } else {
        self.semanticContentAttribute = [SystemConfigUtils isRightToLeftLanguage] ?  UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
        self.leftView = imgView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)setErrorTip:(NSString *)errorTip {
    _errorTip = errorTip;
    self.errorTipLabel.text = errorTip;
    [self.errorTipLabel sizeToFit];
}

- (void)setErrorFontSize:(CGFloat)errorFontSize {
    _errorFontSize = errorFontSize;
    self.errorTipLabel.font = [UIFont systemFontOfSize:errorFontSize];
}

- (void)setErrorTipColor:(UIColor *)errorTipColor {
    _errorTipColor = errorTipColor;
    self.errorTipLabel.textColor = errorTipColor;
}

#pragma mark - Getter
- (UILabel *)placeholderAnimationLabel {
    if (!_placeholderAnimationLabel) {
        _placeholderAnimationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderAnimationLabel.userInteractionEnabled = NO;
        _placeholderAnimationLabel.font = self.font;
        _placeholderAnimationLabel.textColor = ZFCOLOR(212, 212, 212, 1);
    }
    return _placeholderAnimationLabel;
}

- (UILabel *)errorTipLabel {
    if (!_errorTipLabel) {
        _errorTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _errorTipLabel.userInteractionEnabled = NO;
        _errorTipLabel.numberOfLines = 0;
        _errorTipLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - self.floatingLabelXPadding;
        _errorTipLabel.alpha = 0;
        _errorTipLabel.hidden = YES;
    }
    return _errorTipLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ZFCOLOR(225, 225, 225, 1);
    }
    return _lineView;
}

- (CALayer *)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [CALayer layer];
        _lineLayer.frame = CGRectMake(0,0, 0, kLineWidth);
        _lineLayer.anchorPoint = CGPointMake(0, 0.5);
        _lineLayer.backgroundColor = ZFCOLOR(51, 51, 51, 1).CGColor;
    }
    return _lineLayer;
}


@end
