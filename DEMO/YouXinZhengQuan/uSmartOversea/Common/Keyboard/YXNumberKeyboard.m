//
//  YXNumberKeyboard.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXNumberKeyboard.h"
#import "uSmartOversea-Swift.h"
#import "UITextField+MicrometerLevelFormat.h"
#import "UIResponder+TextInput.h"

#define kYXNumberKeyboardHeight 200

#define kYXNumberKeyboardBtnHeight (kYXNumberKeyboardHeight/4)

@implementation YXNumberKeyboard


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, YXConstant.screenWidth, kYXNumberKeyboardHeight + YXConstant.safeAreaInsetsBottomHeight);
        self.backgroundColor = [UIColor whiteColor];
        
        [self registerTextInputNotifications];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterTextInputNotifications];
}

#pragma mark - private

- (void)createKeyBoard
{
    int col = 0;
    NSArray *keyBoards = nil;
    
    switch (self.keyboardType) {
        case YXNumberKeyboardTypeNormal:{
            col = 4;
            keyBoards = @[@(1),@(2),@(3),@(YXKeyboardButtonTypeDelete),@(4),@(5),@(6),@(YXKeyboardButtonTypeNone),@(7),@(8),@(9),@(YXKeyboardButtonTypeComplete),@(YXKeyboardButtonTypeDecimal),@(0),@(YXKeyboardButtonTypeResign),@(YXKeyboardButtonTypeNone)];
        }
            break;
            
        case YXNumberKeyboardTypeSecury:{
            col = 3;
            keyBoards = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(YXKeyboardButtonTypeNone),@(0),@(YXKeyboardButtonTypeDelete)];
        }
            break;
        case YXNumberKeyboardTypeCount: {
            col = 4;
            keyBoards = @[@(1),@(2),@(3),@(YXKeyboardButtonTypeDelete),@(4),@(5),@(6),@(YXKeyboardButtonTypeNone),@(7),@(8),@(9),@(YXKeyboardButtonTypeComplete),@(YXKeyboardButtonType00),@(0),@(YXKeyboardButtonType000),@(YXKeyboardButtonTypeNone)];
        }
            break;
            case YXNumberKeyboardTypeStockPosition: {
                col = 5;
                keyBoards = @[@(YXKeyboardButtonTypeFull),@(1),@(2),@(3),@(YXKeyboardButtonTypeDelete),@(YXKeyboardButtonTypeHalf),@(4),@(5),@(6),@(YXKeyboardButtonTypeNone),@(YXKeyboardButtonTypeOneThird),@(7),@(8),@(9),@(YXKeyboardButtonTypeComplete),@(YXKeyboardButtonTypeQuarter),@(YXKeyboardButtonType00),@(0),@(YXKeyboardButtonTypeResign),@(YXKeyboardButtonTypeNone)];
            }
            break;
        default:
            break;
    }
    
    CGFloat btnWidth = YXConstant.screenWidth / col;
    
    for (int i = 0; i < keyBoards.count; i++) {
        NSInteger keyboardButtonType = [[keyBoards objectAtIndex:i] integerValue];
        YXKeyboardButton *btn = [YXKeyboardButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i % col * btnWidth, i / col * kYXNumberKeyboardBtnHeight, btnWidth, kYXNumberKeyboardBtnHeight);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        if (keyboardButtonType < YXKeyboardButtonTypeNone) {
            btn.KeyboardButtonType = YXKeyboardButtonTypeNumber;
            [btn setTitle:[NSString stringWithFormat:@"%zd",keyboardButtonType] forState:UIControlStateNormal];
        } else {
            btn.KeyboardButtonType = keyboardButtonType;
        }
        
        //页面上的特殊处理
        switch (self.keyboardType) {
            case YXNumberKeyboardTypeNormal:
            case YXNumberKeyboardTypeCount:
            case YXNumberKeyboardTypeStockPosition:
                if (keyboardButtonType == YXKeyboardButtonTypeDelete) {
                    btn.frame = CGRectMake(i % col * btnWidth, i / col * kYXNumberKeyboardBtnHeight, btnWidth, kYXNumberKeyboardBtnHeight * 2);
                } else if (keyboardButtonType == YXKeyboardButtonTypeComplete){
                    btn.frame = CGRectMake(i % col * btnWidth, i / col * kYXNumberKeyboardBtnHeight, btnWidth, kYXNumberKeyboardBtnHeight * 2);
                } else if (keyboardButtonType == YXKeyboardButtonTypeNone) {
                    btn.frame = CGRectZero;
                }
        
                break;
                
            case YXNumberKeyboardTypeSecury:
                break;
                
            default:
                break;
        }
        
    }
}

/**
 点击

 @param sender btn
 */
- (void)btnClick:(YXKeyboardButton *)sender
{
    
    UIView <UITextInput> *textView = [UIResponder currentTextInput];
    switch (sender.KeyboardButtonType) {
            
        case YXKeyboardButtonTypeNumber:
        case YXKeyboardButtonType00:
        case YXKeyboardButtonType000:
        case YXKeyboardButtonTypeDecimal:
            [self inputNumber:sender.titleLabel.text];
            break;
            
        case YXKeyboardButtonTypeDelete:
            if ([NSStringFromClass(textView.class) containsString:@"YXTextField"]) {
                [(UITextField *)textView configSelectedRange];
            }
            [textView deleteBackward];
            if ([NSStringFromClass(textView.class) containsString:@"YXTextField"]) {
                [(UITextField *)textView reformatAsMicrometerLevel:(UITextField *)textView];
            }
            
            break;
            
        case YXKeyboardButtonTypeComplete:
            [textView resignFirstResponder];
            break;
            
        case YXKeyboardButtonTypeResign:
            [textView resignFirstResponder];
            break;
        case YXKeyboardButtonTypeFull:
        case YXKeyboardButtonTypeHalf:
        case YXKeyboardButtonTypeOneThird:
        case YXKeyboardButtonTypeQuarter:
            if (self.stockPositionBtnClickBlock) {
                self.stockPositionBtnClickBlock(sender.KeyboardButtonType);
            }
            break;
        default:
            break;
    }
}


/**
 输入文字

 @param text text
 */
- (void)inputNumber:(NSString *)text
{
    [UIResponder inputText:text];
}

#pragma mark set & get

- (void)setKeyboardType:(YXNumberKeyboardType)keyboardType
{
    _keyboardType = keyboardType;
    [self createKeyBoard];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
