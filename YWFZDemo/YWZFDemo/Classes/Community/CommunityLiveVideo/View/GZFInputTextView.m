//
//  GZFInputTextView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "GZFInputTextView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#define kGZFInputTextNavigationBarHeight (IPHONE_X_5_15 ? 88.0f : 64.0f)
@interface GZFInputTextView()<UITextViewDelegate,UIScrollViewDelegate>
{
    BOOL statusTextView;//当文字大于限定高度之后的状态
    NSString *placeholderText;//设置占位符的文字
    CGFloat _kKeyboardHeight; // 键盘高度
}

@property (nonatomic, strong) UIView           *backGroundView;
@property (nonatomic, strong) UIView           *lineView;
@property (nonatomic, strong) UILabel          *placeholderLabel;
@property (nonatomic, strong) UIButton         *sendButton;
@end

@implementation GZFInputTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxTextHeight = 80;
        [self zfInitView];
        [self zfAutoLayoutView];
        
    }
    
    /**
     点击 空白区域取消
     */
    UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(centerTapClick)];
    [self addGestureRecognizer:centerTap];
    return self;
}

- (void)zfInitView {
    [self addSubview:self.backGroundView];
    [self.backGroundView addSubview:self.lineView];
    [self.backGroundView addSubview:self.textView];
    [self.backGroundView addSubview:self.placeholderLabel];
    [self.backGroundView addSubview:self.sendButton];

}

- (void)zfAutoLayoutView {
    
    [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(49);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.height.mas_equalTo(MIN_PIXEL);
        make.width.mas_equalTo(KScreenWidth);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(6);
        make.leading.mas_equalTo(8.0f);
        make.bottom.mas_equalTo(-6);
    }];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.leading.mas_equalTo(16.0f);
        make.height.mas_equalTo(39);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-9);
        make.trailing.mas_equalTo(-7);
        make.width.mas_equalTo(60);
        make.leading.mas_equalTo(self.textView.mas_trailing).offset(8);
    }];
}

- (void)showTextView {
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.backGroundView.alpha = 0.0;
    [WINDOW addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(WINDOW);
    }];
    
    // 延迟处理第一次显示位置问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
        self.hidden = NO;
    });
}

- (void)showBackGroudView:(CGFloat)height {
    
    CGFloat textH = self.textView.contentSize.height;
    if (textH < 12) {
        textH = 37;
    }
    CGFloat contentH = textH + 12;
    self.backGroundView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-height);
            make.height.mas_equalTo(contentH);
        }];
        self.backGroundView.alpha = 1;
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)hideBackGroudView {
    
    CGFloat textH = self.textView.contentSize.height;
    if (textH < 12) {
        textH = 37;
    }
    CGFloat contentH = textH + 12;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [UIView animateWithDuration:0.2 animations:^{
        [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(0);
            make.height.mas_equalTo(contentH);
        }];
        self.backGroundView.alpha = 0.0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

- (CGFloat)bottomSpaceHeight {
    return kGZFInputTextNavigationBarHeight;
}

//暴露的方法
- (void)setPlaceholderText:(NSString *)text{
    placeholderText = text;
    self.placeholderLabel.text = placeholderText;
}


//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    self.frame = [[UIScreen mainScreen] bounds];
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _kKeyboardHeight = keyboardRect.size.height;
    if (self.textView.text.length == 0) {
//        self.backGroundView.frame = CGRectMake(0, KScreenHeight - _kKeyboardHeight - 49 - [self bottomSpaceHeight], KScreenWidth, 49);
        [self showBackGroudView:_kKeyboardHeight];
    }else{
//        CGRect rect = CGRectMake(0, KScreenHeight - self.backGroundView.frame.size.height - _kKeyboardHeight - [self bottomSpaceHeight], KScreenWidth, self.backGroundView.frame.size.height);
//        self.backGroundView.frame = rect;
        [self showBackGroudView:_kKeyboardHeight];
    }
    
    [self updateSendButtonState:!ZFIsEmptyString(self.textView.text)];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if (self.textView.text.length == 0) {
//        self.backGroundView.frame = CGRectMake(0, 0, KScreenWidth, 49);
//        CGFloat offset = IPHONE_X_5_15 ? KScreenHeight - 49 - 44.0 - 44.0 - 34 : KScreenHeight - 49 - 64;
//        self.frame = CGRectMake(0, offset/*KScreenHeight-49-kNavigationBarHeight*/, KScreenWidth, 49);
        [self hideBackGroudView];

    }else{
//        CGRect rect = CGRectMake(0, 0, KScreenWidth, self.backGroundView.frame.size.height);
//        self.backGroundView.frame = rect;
//        CGFloat tempH = 0;
//        if (self.backGroundView.frame.size.height > 49) {
//            tempH = self.backGroundView.frame.size.height - 49;
//        }
//        CGFloat offset = IPHONE_X_5_15 ? KScreenHeight - 49 - 44.0 - 44.0 - 34 - tempH: KScreenHeight- rect.size.height - 64;
//        self.frame = CGRectMake(0, offset/*KScreenHeight - rect.size.height - kNavigationBarHeight*/, KScreenWidth, self.backGroundView.frame.size.height);
        [self hideBackGroudView];
    }
    
}

- (void)centerTapClick{
    [self.textView resignFirstResponder];
}

#pragma mark --- UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (textView.text.length>99) {
        if ([text isEqualToString:@""]){
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    /**
     *  设置占位符
     */
    
    /*直接利用textView的contentSize算textView高度 和 Y modify by HYZ*/
//    self.backGroundView.height = textView.contentSize.height + 12;
    CGFloat contentH = textView.contentSize.height + 12;
    [self.backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentH);
    }];
    
    if (self.backGroundView.height > 100) {
        self.backGroundView.height = 100;
    }
    // 为了改变 backGroundView 的 y值 随时改变，防止出现遮挡的问题 （球）
//    CGRect rect = CGRectMake(0, KScreenHeight - self.backGroundView.frame.size.height - _kKeyboardHeight - [self bottomSpaceHeight], KScreenWidth, self.backGroundView.frame.size.height);
//    self.backGroundView.frame = rect;
    
    YWLog(@" ---- %lu",(unsigned long)textView.text.length);
    if (textView.text.length >= 100) {
        self.placeholderLabel.text = @"";
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            NSString *tip = [NSString stringWithFormat:ZFLocalizedString(@"InputTextView_%@_message", nil),@"100"];
            ShowToastToViewWithText(nil, tip);
            
        });
        
        [self updateSendButtonState:YES];
    }else if (textView.text.length == 0) {
        self.placeholderLabel.text = placeholderText;
        [self updateSendButtonState:NO];

    }else {
        self.placeholderLabel.text = @"";
        [self updateSendButtonState:YES];
    }
    
    if (self.texeEditBlock) {
        self.texeEditBlock(textView.text);
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.textEndBlock) {
        self.textEndBlock();
    }
}

- (void)updateSendButtonState:(BOOL)state {
    if (state) {
        self.sendButton.userInteractionEnabled = YES;
        [self.sendButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    } else {
        self.sendButton.userInteractionEnabled = NO;
        [self.sendButton setTitleColor:ZFCOLOR(209 , 209, 209, 1.0) forState:UIControlStateNormal];
    }
}

#pragma  mark -- 发送事件
- (void)sendClick:(UIButton *)sender{
    
    [self.textView endEditing:YES];
    if (self.sendTextBlock) {
        self.sendTextBlock(self.textView.text);
    }
    
    //---- 发送成功之后清空 ------//
    self.textView.text = nil;
    self.placeholderLabel.text = placeholderText;
    [self updateSendButtonState:NO];
    CGFloat offset = IPHONE_X_5_15 ? KScreenHeight- 49 - 44.0 - 44.0 - 34 : KScreenHeight- 49 - 64;
    self.frame = CGRectMake(0, offset, KScreenWidth, 49);
    self.backGroundView.frame = CGRectMake(0, 0, KScreenWidth, 49);
}


#pragma mark --- 懒加载控件
- (UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 49)];
        _backGroundView.backgroundColor = [UIColor whiteColor];//YSCOLOR(230, 230, 230, 1.0);
    }
    return _backGroundView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
    }
    return _lineView;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.delegate = self;
        _textView.layer.cornerRadius = 5;
        _textView.backgroundColor = ZFCOLOR(241, 241, 241, 1.0);
        _textView.tintColor = [UIColor blackColor];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _textView.textAlignment = NSTextAlignmentRight;
        }
    }
    return _textView;
}

- (UILabel *)placeholderLabel{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
    }
    return _placeholderLabel;
}

- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [[UIButton alloc]init];
        //        [_sendButton setBackgroundColor:YSCOLOR(209 , 209, 209, 1.0)];
        [_sendButton setTitle:ZFLocalizedString(@"InputTextView_Send",nil) forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendButton setTitleColor:ZFCOLOR(209 , 209, 209, 1.0) forState:UIControlStateNormal];
        [_sendButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateHighlighted];
        [_sendButton addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
        //        _sendButton.layer.cornerRadius = 5;
        _sendButton.userInteractionEnabled = NO;
    }
    return _sendButton;
}

@end
