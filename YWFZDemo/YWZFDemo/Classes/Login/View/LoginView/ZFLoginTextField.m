//
//  YWLoginTextField.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTextField.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "ZFNotificationDefiner.h"

static const CGFloat kFloatingLabelShowAnimationDuration = 0.3f;

@interface YWLoginTextField ()
@property (nonatomic, strong) UILabel    *placeholderAnimationLabel;
@property (nonatomic, copy)   NSString   *placeholderText;
@property (nonatomic, assign) BOOL       moved; //只移动一次
@property (nonatomic, assign) BOOL       isFirstLayout;
@end

@implementation YWLoginTextField
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
        self.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
        self.clipsToBounds = NO;
        self.isFirstLayout = YES;
        self.isSecure = NO;
        self.enablePlaceHoldAnimation = YES;
        [self addSubview:self.placeholderAnimationLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEditing) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEditing) name:kShowPlaceholderAnimationNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.isFirstLayout) {
        self.isFirstLayout = NO;
        CGRect frame = self.placeholderAnimationLabel.frame;
        frame.size = self.size;
        self.placeholderAnimationLabel.frame = frame;
//        self.placeholderAnimationLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
}

// 改变输入文字位置
- (CGRect)textRectForBounds:(CGRect)bounds {
    if ([SystemConfigUtils isRightToLeftShow]) {
        return [super textRectForBounds:bounds];
    }
    CGFloat start_X = bounds.origin.x;
    CGFloat width =  bounds.size.width - 45;
    
    CGRect inset = CGRectMake(start_X, bounds.origin.y, width, bounds.size.height);
    return inset;
}

// 改变光标位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    if ([SystemConfigUtils isRightToLeftShow]) {
        return [super editingRectForBounds:bounds];
    }
    CGFloat start_X =  bounds.origin.x;
    CGFloat width =  bounds.size.width - 45;
    
    CGRect inset = CGRectMake(start_X, bounds.origin.y, width, bounds.size.height);
    return inset;
}

// 改变clear按钮位置
- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    if ([SystemConfigUtils isRightToLeftShow]) {
        if (self.rightButton) {
            rect.origin.x = 22;
        } else{
            rect.origin.x = 0;
        }
    } else {
        if (self.rightButton) {
            rect.origin.x = CGRectGetWidth(self.frame) - rect.size.width - CGRectGetWidth(self.rightButton.frame) - 12;
        }else{
            rect.origin.x = CGRectGetWidth(self.frame) - rect.size.width;
        }
    }
    return CGRectIntegral(rect);
}

#pragma mark - Public method
- (void)resetAnimation {
    if (!self.enablePlaceHoldAnimation) {
        self.placeholderAnimationLabel.hidden = NO;
        return;
    }
    CGFloat y = self.placeholderAnimationLabel.center.y;
    CGFloat x = self.placeholderAnimationLabel.center.x;
    [self backAnimation:x y:y];
}

#pragma mark - Notification action
- (void)changeEditing {
    [self showPlaceholderAnimation];
}

- (void)showPlaceholderAnimation {
    if (!self.enablePlaceHoldAnimation) {
        if (self.text.length) {
            self.placeholderAnimationLabel.hidden = YES;
        }else{
            self.placeholderAnimationLabel.hidden = NO;
        }
        return;
    }
    CGFloat y = self.placeholderAnimationLabel.center.y -2;
    CGFloat x = self.placeholderAnimationLabel.center.x;
    if((self.text.length != 0 && !_moved) || self.isSecure){
        [self moveAnimation:x y:y];
    }else if(self.text.length == 0 && _moved){
        [self backAnimation:x y:y];
    }
}

#pragma mark - Private method
- (void)moveAnimation:(CGFloat)x y:(CGFloat)y {
    _moved = YES;
    self.isSecure = NO;
    [UIView animateWithDuration:kFloatingLabelShowAnimationDuration
                          delay:0.0f
                        options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.placeholderAnimationLabel.font = self.placeholderAnimationFont;
                         self.placeholderAnimationLabel.textColor = self.placeholderNormalColor;
                         self.placeholderAnimationLabel.y = -20;
                     } completion:nil];
}

- (void)backAnimation:(CGFloat)x y:(CGFloat)y {
    _moved = NO;

    [UIView animateWithDuration:kFloatingLabelShowAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.placeholderAnimationLabel.font = self.placeholderFont;
                         self.placeholderAnimationLabel.textColor = self.placeholderNormalColor;
                         self.placeholderAnimationLabel.y = 0;
                     } completion:nil];
}

#pragma mark - Setter
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholderText = placeholder;
    self.placeholderAnimationLabel.text = placeholder;
}

- (void)setClearImage:(UIImage *)clearImage {
    _clearImage = clearImage;
    if (clearImage) {
        UIButton *button = [self valueForKey:@"_clearButton"];
        [button setImage:self.clearImage forState:UIControlStateNormal];
    }
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    self.placeholderAnimationLabel.font = placeholderFont;
}

- (void)setPlaceholderAnimationFont:(UIFont *)placeholderAnimationFont {
    _placeholderAnimationFont = placeholderAnimationFont;
}

- (void)setPlaceholderNormalColor:(UIColor *)placeholderNormalColor {
    _placeholderNormalColor = placeholderNormalColor;
    self.placeholderAnimationLabel.textColor = placeholderNormalColor;
}

- (void)setCursorColor:(UIColor *)cursorColor{
    self.tintColor = cursorColor;
}

-(void)setEnablePlaceHoldAnimation:(BOOL)enablePlaceHoldAnimation
{
    _enablePlaceHoldAnimation = enablePlaceHoldAnimation;
}

#pragma mark - Getter
- (UILabel *)placeholderAnimationLabel {
    if (!_placeholderAnimationLabel) {
        _placeholderAnimationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth*0.7, 30)];
        _placeholderAnimationLabel.backgroundColor = [UIColor clearColor];
        _placeholderAnimationLabel.userInteractionEnabled = NO;
        _placeholderAnimationLabel.textColor = ZFCOLOR(212, 212, 212, 1);
    }
    return _placeholderAnimationLabel;
}

@end
