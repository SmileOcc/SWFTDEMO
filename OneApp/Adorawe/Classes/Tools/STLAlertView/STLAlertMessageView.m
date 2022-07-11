//
//  STLAlertMessageView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLAlertMessageView.h"

#define STLAlertBtnHeight (44)
#define STLButtonTagFlag  (2020)


@implementation STLAlertMessageView


+ (void)showMessage:(NSString *)msg btnTitles:(NSArray *)otherBtnTitles {
    [STLAlertMessageView alertWithCloseBtnImage:nil alerTitle:@"" alerMessage:msg otherBtnTitles:otherBtnTitles otherBtnAttributes:nil alertCallBlock:nil];
}

+ (instancetype)alertWithCloseBtnImage:(UIImage *)closeBtnImage
                             alerTitle:(NSString *)alerTitle
                           alerMessage:(id)alerMessage
                        otherBtnTitles:(NSArray *)otherBtnTitles
                    otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
                        alertCallBlock:(STLAlertTipCallBlock)alertCallBlock {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    return [[STLAlertMessageView alloc] initWithFrame:frame alertWithCloseBtnImage:closeBtnImage alerTitle:alerTitle alerMessage:alerMessage otherBtnTitles:otherBtnTitles otherBtnAttributes:otherBtnAttributes alertCallBlock:alertCallBlock];
}

- (instancetype)initWithFrame:(CGRect)frame
       alertWithCloseBtnImage:(UIImage *)closeBtnImage
                    alerTitle:(NSString *)alerTitle
                  alerMessage:(id)alerMessage
               otherBtnTitles:(NSArray *)otherBtnTitles
           otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
               alertCallBlock:(STLAlertTipCallBlock)alertCallBlock {
    self = [super initWithFrame:frame];
    if(self){
        self.alerTitle = alerTitle;
        self.alerMessage = alerMessage;
        self.closeBtnImage = closeBtnImage;
        self.otherBtnTitles = otherBtnTitles;
        self.otherBtnAttributes = otherBtnAttributes;
        self.alertCallBlock = alertCallBlock;
        
        [self stlInitView];
        [self stlAutoLayoutView];
        
        [self setUIData];
        [self setupAllOtherButton];
        [self show];
    }
    
    return self;
}


/**
 * 设置显示文本
 */
- (void)setUIData
{
    self.title.text = self.alerTitle;
    self.cotentTip.text = self.alerMessage;
    self.closeBtn.hidden = YES;
    if (self.closeBtnImage) {
        self.closeBtn.hidden = NO;
        [self.closeBtn setImage:self.closeBtnImage forState:0];
    }
    
    if (STLIsEmptyString(self.alerTitle) && self.closeBtn.isHidden) {
        [self.cotentTip mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.container.mas_top).offset(15);
        }];
    };
    
    NSAttributedString * attributedStr;
    if ([self.alerMessage isKindOfClass:[NSAttributedString class]]) {
        attributedStr = (NSAttributedString *)self.alerMessage;
    } else {
        if (STLIsEmptyString(self.alerMessage)) {
            return;
        }
        // 添加行间距
        NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
        paragraph.lineSpacing = 5.0;

        // 字体: 大小 颜色 行间距
        attributedStr = [[NSAttributedString alloc]initWithString:self.alerMessage attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[OSSVThemesColors col_7D7D7D],NSParagraphStyleAttributeName:paragraph}];
    }
    
    self.cotentTip.attributedText = attributedStr;
    self.cotentTip.textAlignment = NSTextAlignmentCenter;
    
}

- (void)stlInitView {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = [OSSVThemesColors stlWhiteColor];
    _container.layer.cornerRadius = 5;
    _container.clipsToBounds = YES;
    [self addSubview:_container];

    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
    [_container addSubview:_closeBtn];
    
    _title = [[UILabel alloc] init];
    _title.textColor = [OSSVThemesColors col_262626];
    _title.font = [UIFont boldSystemFontOfSize:14];
    _title.text = STLLocalizedString_(@"success", nil);
    [_container addSubview:_title];
    _title.hidden = YES;
    
    _cotentTip = [[UILabel alloc] init];
    _cotentTip.numberOfLines = 0;
    _cotentTip.textColor = [OSSVThemesColors col_7D7D7D];
    _cotentTip.font = [UIFont systemFontOfSize:12];
    _cotentTip.textAlignment = NSTextAlignmentCenter;

    [_container addSubview:_cotentTip];
    
//    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _confirmBtn.layer.cornerRadius = 4.0;
//    _confirmBtn.layer.masksToBounds = YES;
//
//    [_confirmBtn setTitle:STLLocalizedString_(@"ok", @"ok") forState:UIControlStateNormal];
//    [_confirmBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
//    [_confirmBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
//    _confirmBtn.backgroundColor = [OSSVThemesColors col_262626];
//    [_container addSubview:_confirmBtn];
    
    _buttomBtnView = [[UIView alloc] initWithFrame:CGRectZero];
    [_container addSubview:_buttomBtnView];
    
}

- (void)stlAutoLayoutView {
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(38);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-38);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(15);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-15);
        make.width.height.mas_equalTo(20);
    }];
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(12);
        make.centerX.mas_equalTo(_container.mas_centerX);
        make.height.mas_equalTo(24);
    }];
    
    [_cotentTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_title.mas_bottom).mas_offset(8);
        make.centerX.mas_equalTo(_container.mas_centerX);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
    }];
    
//    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(_cotentTip.mas_bottom).mas_offset(24);
//        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
//        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
//        make.height.mas_equalTo(44);
//        make.bottom.mas_equalTo(_container.mas_bottom).offset(-24);
//    }];
    
    CGFloat height = self.otherBtnTitles.count * (STLAlertBtnHeight + 12) - 12;
    [self.buttomBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cotentTip.mas_bottom).offset(37);
        make.leading.mas_equalTo(self.container).offset(24);
        make.trailing.mas_equalTo(self.container).offset(-24);
        make.height.mas_equalTo(height);
        make.bottom.mas_equalTo(self.container.mas_bottom).offset(-24);
    }];
}

/**
 * 弹框按钮操作事件
 */
- (void)allButtonAction:(UIButton *)button
{
    NSInteger index = button.tag-STLButtonTagFlag;
    NSString *title = self.otherBtnTitles[index];
    if (self.alertCallBlock) {
        self.alertCallBlock(index, title);
    }
    //关闭视图
    [self dismiss];
}


//+ (void)showMessage:(NSString *)msg {
//    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    for (UIView *windowSubView in window.subviews) {
//        if ([windowSubView isKindOfClass:[STLAlertMessageView class]]) {
//            [windowSubView removeFromSuperview];
//            break;
//        }
//    }
//    
//    
//    
//    
//    STLAlertMessageView *alertView = [[STLAlertMessageView alloc] init];
//    alertView.cotentTip.attributedText = attributedStr;
//    
//    [window addSubview:alertView];
//    alertView.alpha = 0.0;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        alertView.alpha = 1.0;
//        [alertView.container mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(alertView.mas_centerY);
//        }];
//    }];
//}

- (void)show{
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[STLAlertMessageView class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
    
    //添加AlertView到窗口上
    [window endEditing:YES];
    [window addSubview:self];
    
    self.alpha = 0.0;
    self.hidden = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    self.container.transform = CGAffineTransformMakeScale(1.12, 1.12);
    [UIView animateWithDuration:0.15f animations:^{
        self.alpha = 1.0;
        self.container.transform = CGAffineTransformIdentity;
    }];
}


- (void)dismiss {

    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0;
        self.container.transform = CGAffineTransformMakeScale(0.8, 0.8);
         [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.closeBlock) {
            self.closeBlock();
        }
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];

}


-(void)dealloc {

}

/**
 * 设置全部操作按钮
 */
- (void)setupAllOtherButton
{
    UIButton *lastBtn = nil;
    for (int i=0; i < self.otherBtnTitles.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitleColor:[OSSVThemesColors col_999999] forState:UIControlStateNormal];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [OSSVThemesColors col_CCCCCC].CGColor;
        button.tag = STLButtonTagFlag+i;
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        [self.buttomBtnView addSubview:button];
        [button addTarget:self action:@selector(allButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //最有一个按钮背景色位黄色
        if (i == 0) {
            button.backgroundColor = [OSSVThemesColors col_262626];
            button.layer.borderColor = [OSSVThemesColors col_262626].CGColor;
            [button setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
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
                make.height.mas_equalTo(STLAlertBtnHeight);
            }];
        } else {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.mas_equalTo(self.buttomBtnView);
                make.height.mas_equalTo(STLAlertBtnHeight);
            }];
        }
        lastBtn = button;
    }
}

@end
