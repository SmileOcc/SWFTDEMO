//
//  ZFAlertTipView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAlertTipView.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "Masonry.h"

#define ZFButtonTagFlag  (2018)
#define ZFAlertBtnHeight (46)

@interface ZFAlertTipView ()
@property (nonatomic, strong) UIImage *topImage;
@property (nonatomic, strong) NSString *alerTitle;
@property (nonatomic, strong) NSString *alerMessage;
@property (nonatomic, strong) UIImage *closeBtnImage;
@property (nonatomic, strong) NSArray *otherBtnTitles;
@property (nonatomic, strong) NSArray *otherBtnAttributes;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *messageLab;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *buttomBtnView;
/** AlertView消失回调 */
@property (nonatomic, copy) void (^closeBlock)(void);
/** AlertView消失回调 */
@property (nonatomic, copy) void (^alertCallBlock)(NSInteger buttonIndex, NSString *btnTitle);
@end

@implementation ZFAlertTipView

+ (instancetype)alertWithTopImage:(UIImage *)topImage
                    closeBtnImage:(UIImage *)closeBtnImage
                         alerTitle:(NSString *)alerTitle
                       alerMessage:(NSString *)alerMessage
                    otherBtnTitles:(NSArray *)otherBtnTitles
                otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
                    alertCallBlock:(ZFAlertTipCallBlock)alertCallBlock
{
    CGRect frame = [UIScreen mainScreen].bounds;
    return [[ZFAlertTipView alloc] initWithFrame:frame
                              alertWithCallBlock:alertCallBlock
                                        topImage:topImage
                                       alerTitle:alerTitle
                                     alerMessage:alerMessage
                                   closeBtnImage:closeBtnImage
                                  otherBtnTitles:otherBtnTitles
                              btnTitleAttributes:otherBtnAttributes];
}

- (instancetype)initWithFrame:(CGRect)frame
           alertWithCallBlock:(ZFAlertTipCallBlock)alertCallBlock
                     topImage:(UIImage *)topImage
                    alerTitle:(NSString *)alerTitle
                  alerMessage:(NSString *)alerMessage
                closeBtnImage:(UIImage *)closeBtnImage
               otherBtnTitles:(NSArray *)otherBtnTitles
           btnTitleAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
{
    self = [super initWithFrame:frame];
    if(self){
        self.topImage = topImage;
        self.alerTitle = alerTitle;
        self.alerMessage = alerMessage;
        self.closeBtnImage = closeBtnImage;
        self.otherBtnTitles = otherBtnTitles;
        self.otherBtnAttributes = otherBtnAttributes;
        self.alertCallBlock = alertCallBlock;
        
        [self zfInitView];
        [self zfAutoLayoutView];
        
        [self setUIData];
        
        //设置全部操作按钮
        [self setupAllOtherButton];
        
        //显示
        [self showYSAlertViewToWindow];
    }
    return self;
}

/**
 * 设置显示文本
 */
- (void)setUIData
{
    self.titleLab.text = self.alerTitle;
    self.messageLab.text = self.alerMessage;
    self.topImageView.image = self.topImage;
    [self.closeButton setImage:self.closeBtnImage forState:0];
}


/**
 * 初始化UI
 */
- (void)zfInitView
{
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.topImageView];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.messageLab];
    [self.contentView addSubview:self.buttomBtnView];
}

/**
 * 布局UI
 */
- (void)zfAutoLayoutView
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(16);
        make.trailing.mas_equalTo(self).offset(-16);
        make.center.mas_equalTo(self);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(12);
        make.trailing.mas_equalTo(self.contentView).offset(-12);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.centerX);
        make.centerY.mas_equalTo(self.contentView.mas_top);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.centerX);
        make.top.mas_equalTo(self.topImageView.mas_bottom).offset(36);
        make.leading.mas_equalTo(self.contentView).offset(36);
        make.trailing.mas_equalTo(self.contentView).offset(-36);
    }];
    
    [self.messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.centerX);
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(20);
        make.leading.mas_equalTo(self.contentView).offset(36);
        make.trailing.mas_equalTo(self.contentView).offset(-36);
    }];
    
    CGFloat height = self.otherBtnTitles.count * (ZFAlertBtnHeight + 12) - 12;
    [self.buttomBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLab.mas_bottom).offset(37);
        make.leading.mas_equalTo(self.contentView).offset(36);
        make.trailing.mas_equalTo(self.contentView).offset(-36);
        make.height.mas_equalTo(height);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-36);
    }];
}

/**
 * 弹框按钮操作事件
 */
- (void)allButtonAction:(UIButton *)button
{
    NSInteger index = button.tag-ZFButtonTagFlag;
    NSString *title = self.otherBtnTitles[index];
    if (self.alertCallBlock) {
        self.alertCallBlock(index, title);
    }
    //关闭视图
    [self closeButtonAction:button];
}

#pragma mark - 显示，退出弹框

/**
 *  显示弹框
 */
- (void)showYSAlertViewToWindow
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
 * 关闭弹框
 */
- (void)closeButtonAction:(UIButton *)button
{
    [UIView animateWithDuration:0.1f animations:^{
        self.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (self.closeBlock) {
            self.closeBlock();
        }
        [self removeFromSuperview];
    }];
}

#pragma mark -===========懒加载子视图===========

/**
 * 初始内容视图
 */
- (UIView *)contentView
{
    if(!_contentView){
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 15;
    }
    return _contentView;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _topImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont boldSystemFontOfSize:18];
        _titleLab.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _titleLab;
}

- (UILabel *)messageLab {
    if (!_messageLab) {
        _messageLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLab.font = [UIFont systemFontOfSize:16];
        _messageLab.textAlignment = NSTextAlignmentCenter;
        _messageLab.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _messageLab.numberOfLines = 0;
    }
    return _messageLab;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.tag = followBtnTag;
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _closeButton.layer.borderColor = ZFCOLOR(255, 168, 0, 1).CGColor;
        [_closeButton setTitleColor:ZFCOLOR(255, 168, 0, 1) forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.closeBtnImage) {
            [_closeButton setImage:self.closeBtnImage forState:UIControlStateNormal];
        } else {
            [_closeButton setTitle:@"Close" forState:0];
        }
    }
    return _closeButton;
}

/**
 * 初始内容视图
 */
- (UIView *)buttomBtnView
{
    if(!_buttomBtnView){
        _buttomBtnView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _buttomBtnView;
}

/**
 * 设置全部操作按钮
 */
- (void)setupAllOtherButton
{
    UIButton *lastBtn = nil;
    for (int i=0; i < self.otherBtnTitles.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button setTitleColor:ZFCOLOR(255, 168, 0, 1) forState:UIControlStateNormal];
        button.layer.borderWidth = 1;
        button.layer.borderColor = ZFCOLOR(255, 168, 0, 1).CGColor;
        button.tag = ZFButtonTagFlag+i;
        [self.buttomBtnView addSubview:button];
        [button addTarget:self action:@selector(allButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //最有一个按钮背景色位黄色
        if (i > 0 && i == self.otherBtnTitles.count-1) {
            button.backgroundColor = ZFCOLOR(255, 168, 0, 1);
        }
        
        NSString *btnTitle = self.otherBtnTitles[i];
        btnTitle = ([btnTitle isKindOfClass:[NSString class]] && btnTitle.length>0) ? btnTitle : @"Close";
        
        NSDictionary *attributedDic = nil;
        if (self.otherBtnAttributes.count > i) {
            attributedDic = self.otherBtnAttributes[i];
        }
        
        if (attributedDic) {
            NSAttributedString *btnTitleAttr = [[NSAttributedString alloc] initWithString:btnTitle attributes:attributedDic];
            [button setAttributedTitle:btnTitleAttr forState:0];
        } else {
            [button setTitle:btnTitle forState:UIControlStateNormal];
        }
        
        if (lastBtn) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastBtn.mas_bottom).offset(12);
                make.leading.trailing.mas_equalTo(self.buttomBtnView);
                make.height.mas_equalTo(ZFAlertBtnHeight);
            }];
        } else {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.mas_equalTo(self.buttomBtnView);
                make.height.mas_equalTo(ZFAlertBtnHeight);
            }];
        }
        lastBtn = button;
    }
}

@end
