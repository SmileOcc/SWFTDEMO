//
//  ZFCouponBaseTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  优惠券视图，基类布局

#import <UIKit/UIKit.h>

@interface ZFCouponBaseTableViewCell : UITableViewCell

///背景视图
@property (nonatomic, strong) UIView        *contentBackView;
///背景图片
@property (nonatomic, strong) UIImageView   *contentImageView;
///优惠金额或者优惠折扣label
@property (nonatomic, strong) UILabel       *codeLabel;
///时间label
@property (nonatomic, strong) UILabel       *dateLabel;
///优惠明细label
@property (nonatomic, strong) UILabel       *expiresLabel;
///选择image
@property (nonatomic, strong) UIImageView   *selectedImageView;
///标签button
@property (nonatomic, strong) UIButton      *tagBtn;
///提示button "大问号"
@property (nonatomic, strong) UIButton      *tipButton;
///优惠券失效视图
@property (nonatomic, strong) UIImageView *invalidCouponIcon;
///优惠券失效文字
@property (nonatomic, strong) UILabel *invalidText;
///自定义增加视图 需要调用 super
- (void)zfInitView;

///子类继承重写布局 需要调用 super 不然没有布局
- (void)zfAutoLayoutView;

#pragma mark - 事件

- (void)showAll;

- (void)hiddenAll;

///提示按钮点击事件
- (void)tipButtonAction;

///更多按钮点击事件
- (void)tagBtnAction;

@end
