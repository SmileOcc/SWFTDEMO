//
//  YSAlertView.h
//  CommonFrameWork
//
//  Created by YW on 2017/3/28.
//  Copyright © 2017年 okdeer. All rights reserved.
//
//	自定义的AlertView弹框

#import <UIKit/UIKit.h>

// title -> NSString、NSAttributedString
typedef void(^YSAlertViewCallBackBlock)(NSInteger buttonIndex, id buttonTitle);
typedef void(^YSAlertViewCancelBlock)(id cancelTitle);
typedef void(^YSAlertViewInputCallBackBlock)(NSString *inputText);
//取消按钮tag
#define  OKAlertViewCancelBtnTag                2018

@interface YSAlertView : UIView

/** 可以在程序启动后,个性定制YSAlertView单个控件的外观, App设置一次全局生效
 *  用法: [YSAlertView appearance].titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], ....};
 */
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *messageTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *otherBtnTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *themeColorBtnTitleAttributes UI_APPEARANCE_SELECTOR;//APP的主色按钮外观

/**
 自定义的AlertView弹框

 @param title               弹框标题->(支持 NSString、NSAttributedString)
 @param message             弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle   取消按钮标题->(支持 NSString、NSAttributedString)
 @param cancelButtonBlock   点击取消按钮回调Block
 @param otherButtonBlock    点击其他按钮回调Block
 @param otherButtonTitles   其他按钮标题->(支持 NSString、NSAttributedString)
 @return 自定义的弹框
 */
+ (instancetype)alertWithTitle:(id)title
                       message:(id)message
             cancelButtonTitle:(id)cancelButtonTitle
             cancelButtonBlock:(YSAlertViewCancelBlock)cancelButtonBlock
              otherButtonBlock:(YSAlertViewCallBackBlock)otherButtonBlock
             otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

/**
 使用方式同上个方法, (效果和上面的方法一样,c函数的方式调用代码量更少)

 @param title               弹框标题->(支持 NSString、NSAttributedString)
 @param message             弹框描述->(支持 NSString、NSAttributedString)
 @param otherButtonTitles   其他按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonBlock    点击其他按钮回调Block
 @param cancelButtonTitle   取消按钮标题->(支持 NSString、NSAttributedString)
 @param cancelButtonBlock   点击取消按钮回调Block
 @return 自定义的弹框
 */
YSAlertView* ShowAlertView(id title, id message, NSArray *otherButtonTitles, YSAlertViewCallBackBlock otherButtonBlock, id cancelButtonTitle, YSAlertViewCancelBlock cancelButtonBlock);

/**
 使用方式同上个方法, (效果和上面的方法一样,c函数的方式调用代码量更少)
 显示一个全部都是竖向按钮的alertView
 @param title               弹框标题->(支持 NSString、NSAttributedString)
 @param message             弹框描述->(支持 NSString、NSAttributedString)
 @param otherButtonTitles   其他按钮标题->(支持 NSString、NSAttributedString)
 @param otherButtonBlock    点击其他按钮回调Block
 @param cancelButtonTitle   取消按钮标题->(支持 NSString、NSAttributedString)
 @param cancelButtonBlock   点击取消按钮回调Block
 @return 自定义的弹框
 */
YSAlertView* ShowVerticalAlertView(id title, id message, NSArray *otherButtonTitles, YSAlertViewCallBackBlock otherButtonBlock, id cancelButtonTitle, YSAlertViewCancelBlock cancelButtonBlock);

/**
 * 单个按钮提示Alert弹框, 没有点击回调事件只做提示使用
 *
 @param title               弹框标题->(支持 NSString、NSAttributedString)
 @param message             弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle   取消按钮标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertSingleBtnView(id title, id message, id cancelButtonTitle);


/**
 *  获取YSAlertView上的指定按钮
 */
- (UIButton *)buttonAtIndex:(NSInteger)index;


/**
 *  给YSAlertView的指定按钮设置标题
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable;


/**
 *  2秒自动消失的系统Alert弹框
 *
 *  @msg 提示标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertToast(id message);


/**
 * 2秒自动消失带标题的系统Alert弹框

 * @param title     提示标题->(支持 NSString、NSAttributedString)
 * @param message   提示信息->(支持 NSString、NSAttributedString)
 */
void ShowAlertToastByTitle(id title, id message);


/**
 * 指定时间消失Alert弹框

 * @param title         提示标题->(支持 NSString、NSAttributedString)
 * @param msg           提示信息->(支持 NSString、NSAttributedString)
 * @param duration      指定消失时间
 * @param dismissBlock  消失回调
 */
void ShowAlertToastDelay(id title, id message, NSTimeInterval duration, void(^dismissBlock)(void));

#pragma mark - 带输入框的系统弹框

/**
 iOS8.0的带输入框的UIAlertController
 @param title           标题
 @param message         提示信息
 @param placeholder     占位文字
 @param cancelTitle     取消按钮标题
 @param otherTitle      其他按钮标题
 @param otherBlock      其他按钮回调
 @param cancelBlock     取消按钮回调
 */
+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                                      text:(NSString *)text
                               placeholder:(NSString *)placeholder
                               cancelTitle:(NSString *)cancelTitle
                                otherTitle:(NSString *)otherTitle
                              keyboardType:(UIKeyboardType)keyboardType
                               buttonBlock:(void (^)(NSString *inputText))otherBlock
                               cancelBlock:(void (^)(void))cancelBlock;


/**
 iOS8.0的带多个输入框的UIAlertController
 @param title           标题
 @param message         提示信息
 @param cancelTitle     取消按钮标题
 @param otherTitle      其他按钮标题
 @param textFieldBlock  在弹框之前回调给外部可自定义输入框的属性
 @param otherBlock      其他按钮回调
 @param cancelBlock     取消按钮回调
 */
+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                               cancelTitle:(NSString *)cancelTitle
                                otherTitle:(NSString *)otherTitle
                            textFieldCount:(NSInteger)textFieldCount
                            textFieldBlock:(void (^)(NSArray<UITextField *> *textFieldArr))textFieldBlock
                               buttonBlock:(void (^)(NSArray<NSString *> *inputTextArr))otherBlock
                               cancelBlock:(void (^)(void))cancelBlock;

/**
 带输入框的底部错误提示的 alertView
 @param title           标题
 @param message         提示信息
 @param placeholder     占位文字
 @param cancelTitle     取消按钮标题
 @param otherTitle      其他按钮标题
 @param errorText       错误提示语
 @param completion      成功按钮回调
 */
+ (YSAlertView *)showBindEmailAlertViewTitle:(NSString *)title
                                     message:(NSString *)message
                                 placeHolder:(NSString *)placeHolder
                                 cancelTitle:(NSString *)cancelTitle
                                  otherTitle:(NSString *)otherTitle
                                   errorText:(NSString *)errorText
                                  completion:(YSAlertViewInputCallBackBlock)completion;

@end


