//
//  STLAlertBottomView.h
// XStarlinkProject
//
//  Created by odd on 2021/3/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


//进制颜色转换
#ifndef STLAlertBottomColorFromHex
#define STLAlertBottomColorFromHex(hexValue)                 ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

#define  STLAlertBottomView_KitMargin                  12

//取消按钮主色调颜色 (默认为系统 UIAlertView的蓝色)
#ifndef  STLAlertBottomView_MainColor
#define  STLAlertBottomView_MainColor                  STLAlertBottomColorFromHex(0x2F7AFF)
#endif

//按钮普通状态字体颜色
#ifndef  STLAlertBottomView_BtnTitleNorColor
#define  STLAlertBottomView_BtnTitleNorColor           STLAlertBottomColorFromHex(0x323232)
#endif

//按钮高亮状态背景颜色
#ifndef  STLAlertBottomView_BtnBgHighColor
#define  STLAlertBottomView_BtnBgHighColor             [STLAlertBottomColorFromHex(0xe8e8e8) colorWithAlphaComponent:0.5]
#endif

//按钮普通状态字体颜色
#ifndef  STLAlertBottomView_BtnTitleFormateNorColor
#define  STLAlertBottomView_BtnTitleFormateNorColor           STLAlertBottomColorFromHex(0x666666)
#endif

//按钮普通状态字体颜色
#ifndef  STLAlertBottomView_BtnTitleFormateHighColor
#define  STLAlertBottomView_BtnTitleFormateHighColor           STLAlertBottomColorFromHex(0xFFFFFF)
#endif

//按钮颜色
#ifndef  STLAlertBottomView_BtnBgFormateHighColor
#define  STLAlertBottomView_BtnBgFormateHighColor             [OSSVThemesColors col_0D0D0D]
#endif

//按钮边框颜色
#ifndef  STLAlertBottomView_BtnBgFormateBorderColor
#define  STLAlertBottomView_BtnBgFormateBorderColor             [STLAlertBottomColorFromHex(0x999999) colorWithAlphaComponent:1.0]
#endif

//按钮不可用状态背景颜色
#ifndef  STLAlertBottomView_BtnBgDisabledColor
#define  STLAlertBottomView_BtnBgDisabledColor         STLAlertBottomColorFromHex(0xe2e2e2)
#endif

//弹框自动消失时间2秒
#ifndef  STLAlertBottomView_ToastDismissTime
#define  STLAlertBottomView_ToastDismissTime           2.0
#endif

//按钮高度
#ifndef  STLAlertBottomView_BigBtnHeight
#define  STLAlertBottomView_BigBtnHeight               44.0f
#endif


typedef void(^STLAlertBottomViewOperateBlock)(NSInteger buttonIndex, id buttonTitle);
typedef void(^STLAlertBottomViewCancelBlock)(id cancelTitle);

@interface STLAlertBottomView : UIView


@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *messageTextAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *otherBtnTitleAttributes UI_APPEARANCE_SELECTOR;


@property (nonatomic, strong) UIView     *contentView;
@property (nonatomic, strong) UIButton   *closeButton;
@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UILabel    *messageLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView      *bottomView;
@property (nonatomic, assign) CGFloat     contentHeight;

@property (nonatomic, copy) STLAlertBottomViewOperateBlock operateBlock;
@property (nonatomic, copy) STLAlertBottomViewCancelBlock cancelBlock;

-(instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttons title:(NSString *)title message:(NSString *)message operateBlock:(STLAlertBottomViewOperateBlock)operateBlock cancelBlock:(STLAlertBottomViewCancelBlock)cancelBlock;

+(void)alertBottomShowButtons:(NSArray *)buttons title:(NSString *)title message:(NSString *)message operateBlock:(STLAlertBottomViewOperateBlock)operateBlock cancelBlock:(STLAlertBottomViewCancelBlock)cancelBlock;

/**
 * 移除window上已存在的OKAlertView
 */
+ (void)removeOkAlertFromWindow;
@end

