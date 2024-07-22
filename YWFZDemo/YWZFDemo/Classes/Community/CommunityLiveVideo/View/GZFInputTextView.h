//
//  GZFInputTextView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZFInputTextView : UIView

@property (nonatomic, assign) CGFloat    maxTextHeight;

//------ 发送文本 -----//
@property (nonatomic,copy) void (^sendTextBlock)(NSString *text);
@property (nonatomic, copy) void (^texeEditBlock)(NSString *text);
@property (nonatomic, copy) void (^textEndBlock)(void);


//------  设置占位符 ------//
- (void)setPlaceholderText:(NSString *)text;

@property (nonatomic, strong) UITextView *textView;

- (void)showTextView;

@end

NS_ASSUME_NONNULL_END
