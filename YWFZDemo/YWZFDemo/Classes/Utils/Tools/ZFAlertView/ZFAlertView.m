//
//  YSAlertView.m
//  AlertOrActionSheetDemo
//
//  Created by YW on 2016/12/29.
//  Copyright © 2017年 okdeer. All rights reserved.
//

#import "YSAlertView.h"
#import <objc/message.h>
#import "Constants.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "CustomTextField.h"

//进制颜色转换
#ifndef OKColorFromHex
#define OKColorFromHex(hexValue)                 ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

//屏幕宽度
#ifndef OKFullScreenWidth
#define OKFullScreenWidth                       ([UIScreen mainScreen].bounds.size.width)
#endif

//弹框字体大小
#ifndef  OKFONTDEFAULT
#define  OKFONTDEFAULT(fontSize)                ([UIFont systemFontOfSize:fontSize])
#endif

//取消按钮主色调颜色 (默认为系统 UIAlertView的蓝色)
#ifndef  OKAlertView_MainColor
#define  OKAlertView_MainColor                  OKColorFromHex(0x2F7AFF)
#endif

//按钮普通状态字体颜色
#ifndef  OKAlertView_BtnTitleNorColor
#define  OKAlertView_BtnTitleNorColor           OKColorFromHex(0x323232)
#endif

//按钮高亮状态背景颜色
#ifndef  OKAlertView_BtnBgHighColor
#define  OKAlertView_BtnBgHighColor             [OKColorFromHex(0xe8e8e8) colorWithAlphaComponent:0.5]
#endif

//按钮不可用状态背景颜色
#ifndef  OKAlertView_BtnBgDisabledColor
#define  OKAlertView_BtnBgDisabledColor         OKColorFromHex(0xe2e2e2)
#endif

//弹框自动消失时间2秒
#ifndef  OKAlertView_ToastDismissTime
#define  OKAlertView_ToastDismissTime           2.0
#endif

//按钮高度
#ifndef  OKAlertView_BigBtnHeight
#define  OKAlertView_BigBtnHeight               44.0f
#endif

//弹框离屏幕边缘宽度
#ifndef  OKAlertView_ScreenSpace
#define  OKAlertView_ScreenSpace    ([UIScreen mainScreen].bounds.size.width<375 ? 25 : OKFullScreenWidth*0.14)
#endif

// 按钮超过最大个数,则滚动
#define  OKAlertView_MaxButtonCount             5
//Label与contenView的间距
#define  OKAlertView_KitMargin                  20
//线条高度
#define  OKAlertView_LineHeight                 (1/[UIScreen mainScreen].scale)
//线条颜色
#define  OKAlertView_LineColor                  OKColorFromHex(0xDDDDDD)
//文本颜色
#define  OKAlertView_LabelColor                 [UIColor blackColor]

//输入框tag
#define  OKAlertView_InputTag                   100403
#define  OKALertView_ErrorLabelTag              100404

@interface YSAlertView ()
<
    UITextFieldDelegate
>
/** AlertView主视图 */
@property (nonatomic, strong) UIView *contentView;
/** AlertView所有按钮数组 */
@property (nonatomic, strong) NSMutableArray *alertAllButtonArr;
/** AlertView普通按钮点击回调 */
@property (nonatomic, copy) YSAlertViewCallBackBlock alertCallBackBlock;
/** AlertView取消按钮点击回调 */
@property (nonatomic, copy) YSAlertViewCancelBlock cancelButtonBlock;
/** AlertView输入框弹窗回调*/
@property (nonatomic, copy) YSAlertViewInputCallBackBlock inputViewCallBackBlock;
/** AlertView取消按钮标题 */
@property (nonatomic, strong) NSString *cancelTitle;
/** AlertView消失时间 */
@property (nonatomic, assign) NSTimeInterval dismissDuration;
/** AlertView消失回调 */
@property (nonatomic, copy) void (^dismissBlock)(void);
@end

@implementation YSAlertView

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
             otherButtonTitles:(id)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION
{
    BOOL canShow = [self judgeCanShowAlert:cancelButtonTitle
                                   message:message
                                     title:title];
	if(!canShow) return nil;

	//包装按钮标题数组
	NSMutableArray *otherTitleArr = [NSMutableArray array];
	va_list otherButtonTitleList;
	va_start(otherButtonTitleList, otherButtonTitles);
	{
        for (NSString *otherButtonTitle = otherButtonTitles; otherButtonTitle != nil; otherButtonTitle = va_arg(otherButtonTitleList, NSString *)) {
            [otherTitleArr addObject:otherButtonTitle];
        }
	}
	va_end(otherButtonTitleList);

	CGRect rect = [UIScreen mainScreen].bounds;
    
    return [[YSAlertView alloc] initWithFrame:rect
                                        title:title
                                      message:message
                            otherButtonTitles:otherTitleArr
                             otherButtonBlock:otherButtonBlock
                            cancelButtonTitle:cancelButtonTitle
                            cancelButtonBlock:cancelButtonBlock];
}

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
YSAlertView* ShowAlertView(id title, id message, NSArray *otherButtonTitles, YSAlertViewCallBackBlock otherButtonBlock, id cancelButtonTitle, YSAlertViewCancelBlock cancelButtonBlock)
{
	BOOL canShow = [YSAlertView judgeCanShowAlert:cancelButtonTitle
										  message:message
											title:title];
	if(!canShow) return nil;

	CGRect rect = [UIScreen mainScreen].bounds;    
    return [[YSAlertView alloc] initWithFrame:rect
                                 title:title
                               message:message
                     otherButtonTitles:otherButtonTitles
                      otherButtonBlock:otherButtonBlock
                     cancelButtonTitle:cancelButtonTitle
                     cancelButtonBlock:cancelButtonBlock];
}

YSAlertView* ShowVerticalAlertView(id title, id message, NSArray *otherButtonTitles, YSAlertViewCallBackBlock otherButtonBlock, id cancelButtonTitle, YSAlertViewCancelBlock cancelButtonBlock)
{
    BOOL canShow = [YSAlertView judgeCanShowAlert:cancelButtonTitle
                                          message:message
                                            title:title];
    if(!canShow) return nil;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    return [[YSAlertView alloc] initWithFrame:rect
                                   isVertical:YES
                                        title:title
                                      message:message
                            otherButtonTitles:otherButtonTitles
                             otherButtonBlock:otherButtonBlock
                            cancelButtonTitle:cancelButtonTitle
                            cancelButtonBlock:cancelButtonBlock];
}

/**
 * 单个按钮提示Alert弹框, 没有点击回调事件只做提示使用
 *
 @param title               弹框标题->(支持 NSString、NSAttributedString)
 @param message             弹框描述->(支持 NSString、NSAttributedString)
 @param cancelButtonTitle   取消按钮标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertSingleBtnView(id title, id message, id cancelButtonTitle){
    [YSAlertView alertWithTitle:title
                        message:message
              cancelButtonTitle:cancelButtonTitle
              cancelButtonBlock:nil
               otherButtonBlock:nil
              otherButtonTitles:nil];
}

/**
 根据条件判断能否显示弹框
 */
+ (BOOL)judgeCanShowAlert:(id)cancelButtonTitle message:(id)message title:(id)title
{
	if(!title && !message){
		return NO;
	}

	if (title && ![title isKindOfClass:[NSString class]] &&
		![title isKindOfClass:[NSAttributedString class]]){
		return NO;
	}

	if (message && ![message isKindOfClass:[NSString class]] &&
		![message isKindOfClass:[NSAttributedString class]]){
		return NO;
	}

	if (cancelButtonTitle && ![cancelButtonTitle isKindOfClass:[NSString class]] &&
		![cancelButtonTitle isKindOfClass:[NSAttributedString class]]){
		return NO;
	}
	return YES;
}

#pragma mark - 初始化自定义OKAlertView

- (instancetype)initWithFrame:(CGRect)frame
                   isVertical:(BOOL)isVertical
                        title:(id)title
                      message:(id)message
            otherButtonTitles:(NSArray *)buttonTitleArr
             otherButtonBlock:(YSAlertViewCallBackBlock)alertWithCallBlock
            cancelButtonTitle:(id)cancelTitle
            cancelButtonBlock:(YSAlertViewCancelBlock)cancelButtonBlock
{
    self = [super initWithFrame:frame];
    if(self){
        //点击按钮回调
        self.alertCallBackBlock = alertWithCallBlock;
        self.cancelButtonBlock = cancelButtonBlock;
        
        //取消按钮标题
        self.cancelTitle = cancelTitle;
        
        //设置控件主题色
        self.titleTextAttributes = [YSAlertView appearance].titleTextAttributes ? : nil;
        self.messageTextAttributes = [YSAlertView appearance].messageTextAttributes ? : nil;
        self.otherBtnTitleAttributes = [YSAlertView appearance].otherBtnTitleAttributes ? : nil;
        self.themeColorBtnTitleAttributes = [YSAlertView appearance].themeColorBtnTitleAttributes ? : nil;
        
        //1.先移除window上已存在的OKAlertView
        [self removeOkAlertFromWindow];
        
        //2.初始化弹框标题和描述
        CGFloat lastLabMaxY = [self layoutTitleAndMessageUI:title message:message];
        
        //按钮大于一个就把"取消"按钮放最后， 否则就放第一个
        NSMutableArray *allTitleArr = [NSMutableArray arrayWithArray:buttonTitleArr];
        if(cancelTitle) {
            if (allTitleArr.count == 0) {
                [allTitleArr addObject:cancelTitle];
                
            } else if (allTitleArr.count == 1) {
                [allTitleArr insertObject:cancelTitle atIndex:0];
                
            } else {
                [allTitleArr addObject:cancelTitle];
            }
        }
        
        if (allTitleArr.count > 0) {
            //3.布局所有弹框按钮
            [self layoutMutableBtnUI:allTitleArr
                         contentView:self.contentView
                          lastUImaxY:lastLabMaxY
                          isVertical:isVertical
                        buttonAction:nil];
            
        } else { //没有设置按钮就默认直接延迟2秒退出弹框
            NSInteger dismissTime = self.dismissDuration>0 ? self.dismissDuration : OKAlertView_ToastDismissTime;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissOKAlertView:nil];
            });
        }
        
        //4.显示在窗口
        [self showOKAlertViewToWindow];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
						title:(id)title
					  message:(id)message
			otherButtonTitles:(NSArray *)buttonTitleArr
             otherButtonBlock:(YSAlertViewCallBackBlock)alertWithCallBlock
            cancelButtonTitle:(id)cancelTitle
            cancelButtonBlock:(YSAlertViewCancelBlock)cancelButtonBlock
{
    return [self initWithFrame:frame
                    isVertical:NO
                         title:title
                       message:message
             otherButtonTitles:buttonTitleArr
              otherButtonBlock:alertWithCallBlock
             cancelButtonTitle:cancelTitle
             cancelButtonBlock:cancelButtonBlock];
}

/**
 * 初始化弹框主视图
 */
- (CGFloat)layoutTitleAndMessageUI:(id)title message:(id)message
{
	//弹框矩形视图
	CGFloat contentW = OKFullScreenWidth-OKAlertView_ScreenSpace*2;
	CGRect rect = CGRectMake(OKAlertView_ScreenSpace, 0, contentW, 0);

	UIView *contentView = [[UIView alloc] initWithFrame:rect];
	contentView.backgroundColor = [UIColor whiteColor];
	contentView.layer.cornerRadius = 15;
	contentView.layer.masksToBounds = YES;
	[self addSubview:contentView];
	self.contentView = contentView;

	CGFloat lastLabMaxY = 0;
	CGFloat labelWidth = contentW-OKAlertView_KitMargin*2;

    // 垂直间距
    CGFloat spaceY = OKAlertView_KitMargin * 1.0;
    
	//提示标题
	UILabel *titleLab = nil;
	if (title) {
		titleLab = [[UILabel alloc] init];
		titleLab.backgroundColor = [UIColor clearColor];
		[titleLab setTextColor:OKAlertView_LabelColor];
		[titleLab setTextAlignment:NSTextAlignmentCenter];
		[titleLab setFont:[UIFont boldSystemFontOfSize:17]];
		[contentView addSubview:titleLab];
		titleLab.numberOfLines = 0;

		//赋值文本标题
		id titleObject = title;
		if ([title isKindOfClass:[NSString class]]) {

			if (self.titleTextAttributes) {
				NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.titleTextAttributes];
				[titleLab setAttributedText:titleAttr];
				titleObject = titleAttr;
			} else {
				[titleLab setText:title];
			}

		} else if([title isKindOfClass:[NSAttributedString class]]){
			[titleLab setAttributedText:title];
		}
		CGFloat titleHeight = [YSAlertView calculateTextHeight:titleLab.font
											constrainedToWidth:labelWidth
													textObject:titleObject];
		titleLab.frame = CGRectMake(OKAlertView_KitMargin, spaceY, labelWidth, titleHeight);
		lastLabMaxY = message ? CGRectGetMaxY(titleLab.frame) : (CGRectGetMaxY(titleLab.frame) + spaceY);
	}

	//详细信息
	UILabel *messageLab = nil;
	if (message) {
		messageLab = [[UILabel alloc] init];
		messageLab.backgroundColor = [UIColor clearColor];
		[messageLab setTextColor:OKAlertView_LabelColor];
		[messageLab setFont:OKFONTDEFAULT(13)];
		messageLab.numberOfLines = 0;

		//赋值文本详细信息
		id msgObject = message;
		if ([message isKindOfClass:[NSString class]]) {

			if (self.messageTextAttributes) {
				NSAttributedString *messageAttr = [[NSAttributedString alloc] initWithString:message attributes:self.messageTextAttributes];
				[messageLab setAttributedText:messageAttr];
				msgObject = messageAttr;
			} else {
				[messageLab setText:message];
			}

		} else if([message isKindOfClass:[NSAttributedString class]]){
			[messageLab setAttributedText:message];
		}
        
        CGFloat messageMaxHeight = [UIScreen mainScreen].bounds.size.height * 0.5;

		CGFloat msgHeight = [YSAlertView calculateTextHeight:messageLab.font
										  constrainedToWidth:labelWidth
												  textObject:msgObject];
		CGFloat messageLabY = title ? (lastLabMaxY+OKAlertView_KitMargin*0.4) : spaceY;
        if (msgHeight > messageMaxHeight) {
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(OKAlertView_KitMargin, messageLabY, labelWidth, messageMaxHeight)];
            scrollView.contentSize = CGSizeMake(labelWidth, msgHeight);
            [contentView addSubview:scrollView];
            messageLab.frame = CGRectMake(0, 0, labelWidth, msgHeight);
            [scrollView addSubview:messageLab];
            lastLabMaxY = CGRectGetMaxY(scrollView.frame) + spaceY;
        } else {
            messageLab.frame = CGRectMake(OKAlertView_KitMargin, messageLabY, labelWidth, msgHeight);
            lastLabMaxY = CGRectGetMaxY(messageLab.frame) + spaceY;
            if (msgHeight < 250) {
                [messageLab setTextAlignment:NSTextAlignmentCenter];
            }
            [contentView addSubview:messageLab];
        }
	}

	contentView.bounds = CGRectMake(0, 0, contentW, lastLabMaxY);
	contentView.center = self.center;
	return lastLabMaxY;
}

/**
 * 布局所有Alert按钮
 */
- (void)layoutMutableBtnUI:(NSArray *)allTitleArr
			   contentView:(UIView *)contentView
				lastUImaxY:(CGFloat)lastLabMaxY
                isVertical:(BOOL)isVertical
              buttonAction:(SEL)selector
{
	if (allTitleArr.count==0) return;

    CGFloat lastBtnMaxY = lastLabMaxY;
    CGFloat contentW = OKFullScreenWidth-OKAlertView_ScreenSpace*2;
    CGFloat scrollHeight = OKAlertView_BigBtnHeight * OKAlertView_MaxButtonCount;
    UIView *btnSuperView = contentView;
    
    //Item按钮超过4个的场景就分页滚动
    UIScrollView *scrollView = nil;
    if ((allTitleArr.count - 1) > OKAlertView_MaxButtonCount ) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lastLabMaxY, contentW, scrollHeight)];
        scrollView.showsVerticalScrollIndicator = NO;
        [contentView addSubview:scrollView];
        contentView.bounds = CGRectMake(0, 0, contentW, lastLabMaxY + scrollHeight + OKAlertView_BigBtnHeight);
        btnSuperView = scrollView;
        lastBtnMaxY = 0;
    }

	for (int i = 0 ; i<allTitleArr.count; i++) {
		//分割线
		UILabel *line = [[UILabel alloc] init];
		line.backgroundColor = OKAlertView_LineColor;
        if (scrollView && (i==0 || i==allTitleArr.count-1)) {
            CGFloat lineY = (i==0) ? lastLabMaxY : CGRectGetMaxY(scrollView.frame);
            line.frame = CGRectMake(0, lineY, contentW, OKAlertView_LineHeight);
            [contentView addSubview:line];
        } else {
            line.frame = CGRectMake(0, lastBtnMaxY, contentW, OKAlertView_LineHeight);
            [btnSuperView addSubview:line];
        }

		//按钮
		UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		actionBtn.backgroundColor = [UIColor whiteColor];
		[actionBtn.titleLabel setFont:OKFONTDEFAULT(16)];
		[actionBtn setTitleColor:OKAlertView_BtnTitleNorColor forState:0];
        actionBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        if (!selector) {
            selector = @selector(alertBtnAction:);
        }
		[actionBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
		[actionBtn setBackgroundImage:[YSAlertView ok_imageWithColor:OKAlertView_BtnBgDisabledColor] forState:UIControlStateDisabled];
		[actionBtn setBackgroundImage:[YSAlertView ok_imageWithColor:OKAlertView_BtnBgHighColor] forState:UIControlStateHighlighted];
		[actionBtn setExclusiveTouch:YES];
        
        if (i==allTitleArr.count-1) {
            [contentView addSubview:actionBtn];
        } else {
            [btnSuperView addSubview:actionBtn];
        }
		
        //标记按钮位置，在取按钮的函数(buttonAtIndex:)时用到
        if(self.cancelTitle) {
            if (allTitleArr.count == 1) {
                actionBtn.tag = OKAlertViewCancelBtnTag;
                
            } if (allTitleArr.count == 2) {
                if (i == 0) {
                    actionBtn.tag = OKAlertViewCancelBtnTag;
                } else {
                    actionBtn.tag = 0;
                }
            } else {
                if (i == (allTitleArr.count-1)) {
                    actionBtn.tag = OKAlertViewCancelBtnTag;
                } else {
                    actionBtn.tag = i;
                }
            }
        } else {
            actionBtn.tag = i;
        }
		//赋值按钮标题
		id btnTitleObject = allTitleArr[i];
		if ([btnTitleObject isKindOfClass:[NSString class]]) {

			if (self.otherBtnTitleAttributes) {
				NSAttributedString *btnTitleAttr = [[NSAttributedString alloc] initWithString:btnTitleObject attributes:self.otherBtnTitleAttributes];
				[actionBtn setAttributedTitle:btnTitleAttr forState:0];
			} else {
				[actionBtn setTitle:btnTitleObject forState:0];
			}

		} else if([btnTitleObject isKindOfClass:[NSAttributedString class]]){
            actionBtn.titleLabel.numberOfLines = 0;
            actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
			[actionBtn setAttributedTitle:btnTitleObject forState:0];
		}

		//保存按钮
		[self.alertAllButtonArr addObject:actionBtn];

		//按钮个数大于2个
		if (allTitleArr.count > 2 || isVertical) {
            CGFloat btnY = CGRectGetMaxY(line.frame);
            if (scrollView && (i==0 || i==allTitleArr.count-1)) {
                btnY = (i==0) ? 0 : CGRectGetMaxY(scrollView.frame) + OKAlertView_LineHeight;
            }
            actionBtn.frame = CGRectMake(0, btnY, contentW, OKAlertView_BigBtnHeight);
            
			//大于两个按钮时，变取消按钮显示特定颜色
			if (self.cancelTitle &&
				[self.cancelTitle isKindOfClass:[NSString class]] &&
				[self.cancelTitle isEqualToString:allTitleArr[i]]) {
				[actionBtn setAttributedTitle:nil forState:0];
				[self setupCancelBtnTextStyle:actionBtn cancelTitle:self.cancelTitle];
			}
		} else {
			CGFloat btnY = lastLabMaxY+OKAlertView_LineHeight;
			CGFloat btnW = allTitleArr.count==2 ? contentW/2 : contentW;
			CGFloat lineY = allTitleArr.count==2 ? (i==0?lastLabMaxY:btnY) : lastLabMaxY;
			CGFloat lineW = allTitleArr.count==2 ? (i==0?contentW:OKAlertView_LineHeight) : contentW;
			CGFloat lineH = allTitleArr.count==2 ? (i==0?OKAlertView_LineHeight:OKAlertView_BigBtnHeight) : OKAlertView_BigBtnHeight;
			line.frame = CGRectMake((contentW/2)*i, lineY, lineW, lineH);
			actionBtn.frame = CGRectMake((contentW/2+OKAlertView_LineHeight)*i, btnY, btnW, OKAlertView_BigBtnHeight);

			if (self.cancelTitle && i==allTitleArr.count-1) {
				//只有两个按钮时，第二个按钮显示特定颜色
				[actionBtn setAttributedTitle:nil forState:0];
				[self setupCancelBtnTextStyle:actionBtn cancelTitle:btnTitleObject];
			}
		}
		//记住按钮y位置
        if (scrollView && i==allTitleArr.count-1) {
            lastBtnMaxY = CGRectGetMaxY(scrollView.frame);
        } else {
            lastBtnMaxY = CGRectGetMaxY(actionBtn.frame);
        }
        
        if (scrollView) {
            if (i != allTitleArr.count-1) {
                scrollView.contentSize = CGSizeMake(contentW, CGRectGetMaxY(actionBtn.frame));
            }
        } else {
            contentView.bounds = CGRectMake(0, 0, contentW, CGRectGetMaxY(actionBtn.frame));
        }
        contentView.center = self.center;
	}
    
    if (!scrollView) return;
    NSString *saveKey = @"hasScrolledYSAlertView";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:saveKey]) return;
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:saveKey];
    
    [UIView animateWithDuration:1 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [scrollView setContentOffset:CGPointMake(0, 100)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            [scrollView setContentOffset:CGPointMake(0, 0)];
        }];
    }];
}

/**
 * 设置取消按钮的文本显示样式
 */
- (void)setupCancelBtnTextStyle:(UIButton *)cancelBtn cancelTitle:(id)cancelTitleObject
{
	if ([cancelTitleObject isKindOfClass:[NSString class]]) {

		if (self.themeColorBtnTitleAttributes) {
			NSAttributedString *btnTitleAttr = [[NSAttributedString alloc] initWithString:cancelTitleObject attributes:self.themeColorBtnTitleAttributes];
			[cancelBtn setAttributedTitle:btnTitleAttr forState:0];
		} else {
			[cancelBtn setTitleColor:OKAlertView_MainColor forState:0];
			[cancelBtn setTitle:cancelTitleObject forState:0];
		}

	} else if([cancelTitleObject isKindOfClass:[NSAttributedString class]]){
		[cancelBtn setAttributedTitle:cancelTitleObject forState:0];
	}
}

#pragma mark - 按钮操作事件

/**
 *  获取ActionSheet上的指定按钮
 */
- (UIButton *)buttonAtIndex:(NSInteger)index
{
	if (self.alertAllButtonArr.count>0) {
		for (UIButton *actionBtn in self.alertAllButtonArr) {
			if ([actionBtn isKindOfClass:[UIButton class]] && actionBtn.tag == index) {
				return actionBtn;
			}
		}
	}
	return nil;
}

/**
 *  给ActionSheet的指定按钮设置标题
 */
- (void)setButtonTitleToIndex:(NSInteger)index title:(id)title enable:(BOOL)enable
{
	if (self.alertAllButtonArr.count>0) {
		for (UIButton *actionBtn in self.alertAllButtonArr) {

			if ([actionBtn isKindOfClass:[UIButton class]] && actionBtn.tag == index) {
				actionBtn.enabled = enable;

				//根据文字类型设置标题
				if ([title isKindOfClass:[NSString class]]) {

					if (index == 0) { //取消按钮
						if (self.themeColorBtnTitleAttributes) {
							NSAttributedString *btnTitleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.themeColorBtnTitleAttributes];
							[actionBtn setAttributedTitle:btnTitleAttr forState:0];
						} else {
							[actionBtn setTitle:title forState:0];
						}

					} else { //其他按钮
						if (self.otherBtnTitleAttributes) {
							NSAttributedString *btnTitleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.otherBtnTitleAttributes];
							[actionBtn setAttributedTitle:btnTitleAttr forState:0];
						} else {
							[actionBtn setTitle:title forState:0];
						}
					}

				} else if([title isKindOfClass:[NSAttributedString class]]){
					[actionBtn setAttributedTitle:title forState:0];
				}

				break;
			}
		}
	}
}

#pragma mark - 按钮点击事件

/**
 *  alertView操作按钮事件
 */
- (void)alertBtnAction:(UIButton *)actionBtn
{
	//按钮标题, 如果是主题色按钮, 则用NSString标题
	id titleObjc = nil;
	NSAttributedString *titleAttrStr = actionBtn.currentAttributedTitle;
	if (titleAttrStr) {

		if (actionBtn.tag == 0) { //取消按钮
			if (self.themeColorBtnTitleAttributes) {
				//titleObjc = titleAttrStr.string;
                titleObjc = titleAttrStr;
			} else {
				titleObjc = titleAttrStr;
			}
		} else { //其他按钮
			if (self.otherBtnTitleAttributes) {
				//titleObjc = titleAttrStr.string;
                titleObjc = titleAttrStr;
			} else {
				titleObjc = titleAttrStr;
			}
		}

	} else {
		titleObjc = actionBtn.currentTitle;
	}

    if (actionBtn.tag == OKAlertViewCancelBtnTag) {
        if (self.cancelButtonBlock) {
            self.cancelButtonBlock(titleObjc);
        }
    } else {
        if (self.alertCallBackBlock) {
            self.alertCallBackBlock(actionBtn.tag, titleObjc);
        }
    }
	
	//退出弹框
	[self dismissOKAlertView:nil];
}

- (void)inputButtonAction:(UIButton *)sender
{
    if (sender.tag == 0) { //取消按钮
        [self dismissOKAlertView:nil];
        return;
    }
    UITextField *textField = [self.contentView viewWithTag:OKAlertView_InputTag];
    UILabel *label = [self.contentView viewWithTag:OKALertView_ErrorLabelTag];
    
    BOOL isvalidEmail = [NSStringUtils isValidEmailString:textField.text];
    if (isvalidEmail) {
        if (self.inputViewCallBackBlock) {
            self.inputViewCallBackBlock(textField.text);
            [textField resignFirstResponder];
        }
        [self dismissOKAlertView:nil];
    } else {
        label.hidden = NO;
    }
}

/**
 *  alertView所有按钮数组
 */
- (NSMutableArray *)alertAllButtonArr
{
	if (!_alertAllButtonArr) {
		_alertAllButtonArr = [NSMutableArray array];
	}
	return _alertAllButtonArr;
}

#pragma mark - 2秒自动消失弹框

/**
 *  2秒自动消失的系统Alert弹框
 *
 *  @msg 提示标题->(支持 NSString、NSAttributedString)
 */
void ShowAlertToast(id message) {
	ShowAlertToastByTitle(nil, message);
}


/**
 * 2秒自动消失带标题的系统Alert弹框

 * @param title 提示标题->(支持 NSString、NSAttributedString)
 * @param msg   提示信息->(支持 NSString、NSAttributedString)
 */
void ShowAlertToastByTitle(id title, id message) {
	if (!title && !message) return;
    [YSAlertView alertWithTitle:title
                        message:message
              cancelButtonTitle:nil
              cancelButtonBlock:nil
               otherButtonBlock:nil
              otherButtonTitles:nil];
}

/**
 * 指定时间消失Alert弹框

 * @param title         提示标题->(支持 NSString、NSAttributedString)
 * @param msg           提示信息->(支持 NSString、NSAttributedString)
 * @param duration      消失时间
 * @param dismissBlock  消失回调
 */
void ShowAlertToastDelay(id title, id message, NSTimeInterval duration, void(^dismissBlock)(void)){
	if (!title && !message) return;
    YSAlertView *alertView = [YSAlertView alertWithTitle:title
                                                 message:message
                                       cancelButtonTitle:nil
                                       cancelButtonBlock:nil
                                        otherButtonBlock:nil
                                       otherButtonTitles:nil];
	alertView.dismissDuration = duration;
	alertView.dismissBlock = dismissBlock;
}

#pragma mark - 显示，退出弹框

/**
 *  显示弹框
 */
- (void)showOKAlertViewToWindow
{
	self.alpha = 0.0;
	self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];

	//添加AlertView到窗口上
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window endEditing:YES];
	[window addSubview:self];

	self.contentView.transform = CGAffineTransformMakeScale(1.12, 1.12);
	[UIView animateWithDuration:0.15f animations:^{
		self.alpha = 1;
		self.contentView.transform = CGAffineTransformIdentity;
	}];
}

/**
 *  退出弹框
 */
- (void)dismissOKAlertView:(id)sender
{
	[UIView animateWithDuration:0.1f animations:^{
		self.alpha = 0.0;
		self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
	} completion:^(BOOL finished) {
		if (self.dismissBlock) {
			self.dismissBlock();
		}
		[self removeFromSuperview];
	}];
}

/**
 * 移除window上已存在的OKAlertView
 */
- (void)removeOkAlertFromWindow
{
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	for (UIView *windowSubView in window.subviews) {
		if ([windowSubView isKindOfClass:[YSAlertView class]]) {
			[windowSubView removeFromSuperview];
			break;
		}
	}
}

#pragma mark ========================= 系统带输入的UIAlertView弹框 ========================

+ (UIAlertController *)inputAlertWithTitle:(NSString *)title
                                   message:(NSString *)message
                                      text:(NSString *)text
							   placeholder:(NSString *)placeholder
							   cancelTitle:(NSString *)cancelTitle
								otherTitle:(NSString *)otherTitle
							  keyboardType:(UIKeyboardType)keyboardType
							   buttonBlock:(void (^)(NSString *inputText))otherBlock
							   cancelBlock:(void (^)(void))cancelBlock
{
	UIColor *mainColor = OKAlertView_MainColor;
	NSDictionary *cancelAttributes = [YSAlertView appearance].themeColorBtnTitleAttributes;
	if (cancelAttributes && cancelAttributes[NSForegroundColorAttributeName]) {
		UIColor *color = cancelAttributes[NSForegroundColorAttributeName];
		if ([color isKindOfClass:[UIColor class]]) {
			mainColor = color;
		}
	}

	//警告： 弹出ios8以上的系统框
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

	[alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		if (cancelBlock) {
			cancelBlock();
		}
	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		if (otherBlock) {
			NSString *inputStr = [alertController.textFields[0] text];
			otherBlock(inputStr);
		}
	}]];

	//美化输入框的边框样式, 系统的比较丑
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.tintColor = mainColor;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.placeholder = placeholder;
		textField.keyboardType = keyboardType;
        if ([text isKindOfClass:[NSString class]]) {
            textField.text = text;
        }
        [self setBorderCornerRadius:textField.superview];
        
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            [self setBorderCornerRadius:textField.superview.superview];
		} else {
			/** 是否能获取该属性*/
			Class cls = NSClassFromString(@"_UIAlertControllerTextField");
            if([textField isKindOfClass:cls] && [YSAlertView verifyObject:cls ok_hasVarName:@"_textFieldView"]) {
                UIView *textFieldBorderView = [textField valueForKeyPath:@"_textFieldView"];
                [self setBorderCornerRadius:textFieldBorderView];
            }
		}
	}];
	/** 是否能获取该属性*/
	if(title && [YSAlertView verifyObject:alertController ok_hasVarName:@"attributedTitle"])
		{
		//设置标题为细体
		NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertView_BtnTitleNorColor, NSFontAttributeName: OKFONTDEFAULT(16)}];
		[alertController setValue:titleAttrs forKey:@"attributedTitle"];
		}

	//设置按钮颜色
	if([YSAlertView verifyObject:[UIAlertAction class] ok_hasVarName:@"titleTextColor"])
		{
		for(int i = 0; i<alertController.actions.count; i++)
			{
			UIAlertAction *action = alertController.actions[i];
			if(i == alertController.actions.count-1) {
				//最后一个按钮设置特定颜色
				[action setValue:mainColor forKey:@"titleTextColor"];

			} else {
				[action setValue:OKAlertView_BtnTitleNorColor forKey:@"titleTextColor"];
			}
			}
		}

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	UIViewController *tempVC = window.rootViewController;
	if (tempVC.presentedViewController) {
		tempVC = tempVC.presentedViewController;
	}
	[tempVC presentViewController:alertController animated:YES completion:nil];

	//如果弹框没有一个按钮，则自动延迟隐藏
	if(!cancelTitle && !otherTitle){
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertView_ToastDismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[alertController dismissViewControllerAnimated:YES completion:nil];
		});
	}

	return alertController;
}

+ (void)setBorderCornerRadius:(UIView *)view {
    if ([view isKindOfClass:[UIView class]]) {
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = OKColorFromHex(0xdcdcdc).CGColor;
    }
}

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
                               cancelBlock:(void (^)(void))cancelBlock
{
    UIColor *mainColor = OKAlertView_MainColor;
    NSDictionary *cancelAttributes = [YSAlertView appearance].themeColorBtnTitleAttributes;
    if (cancelAttributes && cancelAttributes[NSForegroundColorAttributeName]) {
        UIColor *color = cancelAttributes[NSForegroundColorAttributeName];
        if ([color isKindOfClass:[UIColor class]]) {
            mainColor = color;
        }
    }
    
    //警告： 弹出ios8以上的系统框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (otherBlock) {
            NSMutableArray *inputArr = [NSMutableArray array];
            for (NSInteger i=0; i<alertController.textFields.count; i++) {
                UITextField *textField = alertController.textFields[i];
                [inputArr addObject:textField.text];
            }
            otherBlock(inputArr);
        }
    }]];
    
    for (NSInteger i=0; i<textFieldCount; i++) {
        //美化输入框的边框样式, 系统的比较丑
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.tintColor = mainColor;
            [self setBorderCornerRadius:textField.superview];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
                [self setBorderCornerRadius:textField.superview.superview];
            } else {
                /** 是否能获取该属性*/
                Class cls = NSClassFromString(@"_UIAlertControllerTextField");
                if([textField isKindOfClass:cls] && [YSAlertView verifyObject:cls ok_hasVarName:@"_textFieldView"]) {
                    
                    UIView *textFieldBorderView = [textField valueForKeyPath:@"_textFieldView"];
                    [self setBorderCornerRadius:textFieldBorderView];
                }
            }
        }];
    }
    
    // 多个弹框时需要自己在外部设置输入框的部分属性样式
    if (textFieldBlock) {
        textFieldBlock(alertController.textFields);
    }
    /** 是否能获取该属性*/
    if(title && [YSAlertView verifyObject:alertController ok_hasVarName:@"attributedTitle"])
    {
        //设置标题为细体
        NSAttributedString *titleAttrs = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:OKAlertView_BtnTitleNorColor, NSFontAttributeName: OKFONTDEFAULT(16)}];
        [alertController setValue:titleAttrs forKey:@"attributedTitle"];
    }
    
    //设置按钮颜色
    if([YSAlertView verifyObject:[UIAlertAction class] ok_hasVarName:@"titleTextColor"])
    {
        for(int i = 0; i<alertController.actions.count; i++)
        {
            UIAlertAction *action = alertController.actions[i];
            if(i == alertController.actions.count-1) {
                //最后一个按钮设置特定颜色
                [action setValue:mainColor forKey:@"titleTextColor"];
                
            } else {
                [action setValue:OKAlertView_BtnTitleNorColor forKey:@"titleTextColor"];
            }
        }
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *tempVC = window.rootViewController;
    if (tempVC.presentedViewController) {
        tempVC = tempVC.presentedViewController;
    }
    [tempVC presentViewController:alertController animated:YES completion:nil];
    
    //如果弹框没有一个按钮，则自动延迟隐藏
    if(!cancelTitle && !otherTitle){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OKAlertView_ToastDismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    }
    return alertController;
}

+ (YSAlertView *)showBindEmailAlertViewTitle:(NSString *)title
                                     message:(NSString *)message
                                 placeHolder:(NSString *)placeHolder
                                 cancelTitle:(NSString *)cancelTitle
                                  otherTitle:(NSString *)otherTitle
                                   errorText:(NSString *)errorText
                                  completion:(YSAlertViewInputCallBackBlock)completion
{
    YSAlertView *alerView = [[YSAlertView alloc] initBindEmailAlertViewTitle:title
                                                                     message:message
                                                                 placeHolder:placeHolder
                                                                 cancelTitle:cancelTitle
                                                                  otherTitle:otherTitle
                                                                   errorText:(NSString *)errorText
                                                                  completion:completion];
    return alerView;
}

- (instancetype)initBindEmailAlertViewTitle:(NSString *)title
                                    message:(NSString *)message
                                placeHolder:(NSString *)placeHolder
                                cancelTitle:(NSString *)cancelTitle
                                 otherTitle:(NSString *)otherTitle
                                  errorText:(NSString *)errorText
                                 completion:(YSAlertViewInputCallBackBlock)completion
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        //1.移除老的
        [self removeOkAlertFromWindow];
        
        self.inputViewCallBackBlock = completion;
        
        //2.初始化弹框标题和描述
        CGFloat lastLabMaxY = [self layoutTitleAndMessageUI:title message:message];

        CGFloat contentW = OKFullScreenWidth-OKAlertView_ScreenSpace*2;
        //3.添加inputView
        CGFloat padding = 14;
        CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(padding, lastLabMaxY, contentW - padding * 2, 36)];
        textField.placeholderPadding = 10;
        textField.placeholder = placeHolder;
        textField.delegate = self;
        textField.tag = OKAlertView_InputTag;
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = ZFC0xCCCCCC().CGColor;
        [self.contentView addSubview:textField];
        
        lastLabMaxY = CGRectGetMaxY(textField.frame);
        //4.添加错误label
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, lastLabMaxY + 3, contentW - padding * 2, 14)];
        errorLabel.textColor = ZFC0xFE5269();
        errorLabel.font = [UIFont systemFontOfSize:12];
        errorLabel.tag = OKALertView_ErrorLabelTag;
        errorLabel.text = errorText;
        errorLabel.hidden = YES;
        [self.contentView addSubview:errorLabel];
        
        lastLabMaxY = CGRectGetMaxY(errorLabel.frame) + 3;
        
        NSMutableArray *allTitleArr = [[NSMutableArray alloc] init];
        [allTitleArr addObject:cancelTitle];
        [allTitleArr addObject:otherTitle];

        [self layoutMutableBtnUI:allTitleArr contentView:self.contentView lastUImaxY:lastLabMaxY isVertical:NO buttonAction:@selector(inputButtonAction:)];
        
        [self showOKAlertViewToWindow];
    }
    return self;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UILabel *errorLabel = [self.contentView viewWithTag:OKALertView_ErrorLabelTag];
    errorLabel.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect oldFrame = self.contentView.frame;
    [UIView animateWithDuration:.3 animations:^{
        self.contentView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - 100, oldFrame.size.width, oldFrame.size.height);
    }];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    CGRect oldFrame = self.contentView.frame;
    [UIView animateWithDuration:.3 animations:^{
        self.contentView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y + 100, oldFrame.size.width, oldFrame.size.height);
    }];
    return YES;
}

#pragma mark - 工具方法,不引入其他类直接写在当前类

/**
 * 根据颜色获取一个单位大小的图片
 */
+ (UIImage *)ok_imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

/**
 *  计算不同文本类型的高度
 */
+ (CGFloat)calculateTextHeight:(UIFont *)font
			constrainedToWidth:(CGFloat)width
					textObject:(id)textObject
{
	if ([textObject isKindOfClass:[NSAttributedString class]]) {
		CGSize textSize = [textObject boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
												   options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine)
												   context:nil].size;
		CGFloat height = ceil(textSize.height);
		//iOS9以下计算有bug
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
			height += 10;
		}
		return height;

	} else if ([textObject isKindOfClass:[NSString class]]) {

		UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
		CGSize textSize;
		NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
		paragraph.lineBreakMode = NSLineBreakByWordWrapping;
		NSDictionary *attributes = @{NSFontAttributeName: textFont,
									 NSParagraphStyleAttributeName: paragraph};

		textSize = [(NSString *)textObject boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
														options:(NSStringDrawingUsesLineFragmentOrigin |
																 NSStringDrawingTruncatesLastVisibleLine)
													 attributes:attributes
														context:nil].size;
		return ceil(textSize.height);
	}
	return 0.0;
}

/**
 *  校验一个类是否有该属性
 */
+ (BOOL)verifyObject:(id)verifyObject ok_hasVarName:(NSString *)name
{
	unsigned int outCount;
	BOOL hasProperty = NO;
	Ivar *ivars = class_copyIvarList([verifyObject class], &outCount);
	for (int i = 0; i < outCount; i++)
		{
		Ivar property = ivars[i];
		NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
		keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];

		NSString *absoluteName = [NSString stringWithString:name];
		absoluteName = [absoluteName stringByReplacingOccurrencesOfString:@"_" withString:@""];
		if ([keyName isEqualToString:absoluteName]) {
			hasProperty = YES;
			break;
		}
		}
	//释放
	free(ivars);
	return hasProperty;
}

- (void)dealloc
{
    ZFLog(@"YSAlertView dealloc");
}

@end
