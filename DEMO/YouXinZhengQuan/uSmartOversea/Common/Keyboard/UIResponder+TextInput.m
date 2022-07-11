//
//  UIResponder+YXKeyBoardFirstResponder.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "UIResponder+TextInput.h"

@implementation UIResponder (TextInput)

static __weak id currentTextInput;

+ (void)inputText:(NSString *)text
{
    UIView <UITextInput> *textInput = [UIResponder currentTextInput];
    NSString *character = [NSString stringWithString:text];
    
    BOOL canEditor = YES;
    if ([textInput isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)textInput;
        if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            canEditor = [textField.delegate textField:textField shouldChangeCharactersInRange:NSMakeRange(textField.text.length, 0) replacementString:character];
        }
        
        if (canEditor) {
            [textField replaceRange:textField.selectedTextRange withText:text];
        }
    }
    
    if ([textInput isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)textInput;
        
        if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            canEditor = [textView.delegate textView:textView shouldChangeTextInRange:NSMakeRange(textView.text.length, 0) replacementText:character];
        }
        
        if (canEditor) {
            [textView replaceRange:textView.selectedTextRange withText:text];
        }
    }
}

- (void)registerTextInputNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)unregisterTextInputNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
}

#pragma mark - UITextFieldView Delegate methods
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification{
    currentTextInput = nil;
    if ([notification.object conformsToProtocol:@protocol(UIKeyInput)]) {
        currentTextInput = notification.object;
    }
}

- (void)textFieldViewDidEndEditing:(NSNotification*)notification{
    currentTextInput = nil;
}

+ (UIView<UITextInput> *)currentTextInput {
    return currentTextInput;
}

@end
