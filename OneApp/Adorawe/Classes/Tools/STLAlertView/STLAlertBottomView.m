//
//  STLAlertBottomView.m
// XStarlinkProject
//
//  Created by odd on 2021/3/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLAlertBottomView.h"

@implementation STLAlertBottomView

/**
 * 移除window上已存在的OKAlertView
 */
+ (void)removeOkAlertFromWindow
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *windowSubView in window.subviews) {
        if ([windowSubView isKindOfClass:[STLAlertBottomView class]]) {
            [windowSubView removeFromSuperview];
            break;
        }
    }
}


+(void)alertBottomShowButtons:(NSArray *)buttons title:(NSString *)title message:(NSString *)message operateBlock:(STLAlertBottomViewOperateBlock)operateBlock cancelBlock:(STLAlertBottomViewCancelBlock)cancelBlock {
    
    CGRect rect = [UIScreen mainScreen].bounds;
    STLAlertBottomView *alertView = [[STLAlertBottomView alloc] initWithFrame:rect buttons:buttons title:title message:message operateBlock:operateBlock cancelBlock:cancelBlock];
    
    [STLAlertBottomView removeOkAlertFromWindow];
    
    //添加AlertView到窗口上
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:alertView];

    alertView.alpha = 0.0;
    [UIView animateWithDuration:0.15f animations:^{
        alertView.alpha = 1;
    }];
    
    [alertView show];
}

-(instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttons title:(NSString *)title message:(NSString *)message operateBlock:(STLAlertBottomViewOperateBlock)operateBlock cancelBlock:(STLAlertBottomViewCancelBlock)cancelBlock {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [OSSVThemesColors col_000000:0.4];
        self.operateBlock = operateBlock;
        self.cancelBlock = cancelBlock;
        
        if (!STLJudgeNSArray(buttons)) {
            buttons = @[];
        }
        
        CGFloat labelWidth = SCREEN_WIDTH-STLAlertBottomView_KitMargin*2;
        CGFloat topSpace = 32;
        CGFloat titleHeight = 0;
        CGFloat msgHeight = 0;
        CGFloat contentHeight = 32;
        CGFloat scrollHeight = 0;
        
        BOOL hasContent = NO;
        if ([title isKindOfClass:[NSString class]]) {
            NSString *tempTitle = (NSString *)title;
            if (tempTitle.length > 0) {
                hasContent = YES;
            }
        }
        if ([title isKindOfClass:[NSAttributedString class]]) {
            NSAttributedString *tempTitle = (NSAttributedString *)title;
            if (tempTitle.string.length > 0) {
                hasContent = YES;
            }
        }
        
        if (hasContent) {
            
            //赋值文本标题
            id titleObject = title;
            if ([title isKindOfClass:[NSString class]]) {
                
                if (self.titleTextAttributes) {
                    NSAttributedString *titleAttr = [[NSAttributedString alloc] initWithString:title attributes:self.titleTextAttributes];
                    [self.titleLabel setAttributedText:titleAttr];
                    titleObject = titleAttr;
                } else {
                    [self.titleLabel setText:title];
                }
                
            } else if([title isKindOfClass:[NSAttributedString class]]){
                [self.titleLabel setAttributedText:(NSAttributedString*)title];
            }
            
            self.titleLabel.textAlignment = NSTextAlignmentCenter;

            titleHeight = [STLAlertBottomView calculateTextHeight:self.titleLabel.font
                                                 constrainedToWidth:labelWidth
                                                         textObject:titleObject];
            contentHeight += titleHeight;
        }
        
        
        if (message) {
            
            //赋值文本详细信息
            id msgObject = message;
            if ([message isKindOfClass:[NSString class]]) {

                if (self.messageTextAttributes) {
                    NSAttributedString *messageAttr = [[NSAttributedString alloc] initWithString:message attributes:self.messageTextAttributes];
                    [self.messageLabel setAttributedText:messageAttr];
                    msgObject = messageAttr;
                } else {
                    // 添加行间距
                    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
                    paragraph.lineSpacing = 5.0;

                    // 字体: 大小 颜色 行间距
                    NSAttributedString *messageAttr = [[NSAttributedString alloc]initWithString:message attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[OSSVThemesColors col_131313],NSParagraphStyleAttributeName:paragraph}];
                    msgObject = messageAttr;
                    [self.messageLabel setAttributedText:messageAttr];

                }

            } else if([message isKindOfClass:[NSAttributedString class]]){
                [self.messageLabel setAttributedText:(NSAttributedString*)message];
            }
            
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
            
            msgHeight = [STLAlertBottomView calculateTextHeight:self.messageLabel.font
                                               constrainedToWidth:labelWidth
                                                       textObject:msgObject];
            
            scrollHeight = msgHeight;
            
            CGFloat maxTitleHeight = [UIScreen mainScreen].bounds.size.height * 0.44;
            if(msgHeight >= maxTitleHeight) {
                scrollHeight = maxTitleHeight;
            }
            
            if (titleHeight > 0) {
                contentHeight += scrollHeight + 12;
            } else {
                contentHeight += scrollHeight;
            }
        }
        
        CGFloat bottomSpaec = (SCREEN_HEIGHT > 736.0)?34:12;
        contentHeight += 52 * buttons.count + 12;
        contentHeight += bottomSpaec;
        
        self.backgroundColor = [OSSVThemesColors col_000000:0.4];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.closeButton];
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.messageLabel];
        
        [self.contentView addSubview:self.bottomView];


        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.top.mas_equalTo(self.contentView.mas_top);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(topSpace);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        }];
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.scrollView);
            make.width.mas_equalTo(labelWidth);
        }];
        
        if (titleHeight > 0) {
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(12);
                make.height.mas_equalTo(scrollHeight);
            }];
        } else {
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
                make.top.mas_equalTo(self.titleLabel.mas_top);
                make.height.mas_equalTo(scrollHeight);
            }];
        }
        
        if (message) {
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self.contentView);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-bottomSpaec);
                make.height.mas_equalTo(buttons.count * 52);
                make.top.mas_equalTo(self.scrollView.mas_bottom).offset(12);
            }];
        } else if(titleHeight > 0){
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self.contentView);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-bottomSpaec);
                make.height.mas_equalTo(buttons.count * 52);
                make.top.mas_equalTo(self.scrollView.mas_top);
            }];
        }
       
        
        [self layoutButtons:buttons];
        self.contentHeight = contentHeight;
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, contentHeight);

        [self.contentView stlAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4, 4)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)show {
    
    self.hidden = NO;
    
    if (self.contentHeight <= 0) {
        self.contentHeight = 532 + 32;
    }
    
    //121
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetHeight(self.frame) - self.contentHeight;
        self.contentView.frame = frame;
    }];
}
- (void)dismiss {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = SCREEN_HEIGHT;
        self.contentView.frame = frame;
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)actionClose:(UIButton *)sender {
    [self dismiss];
}

- (void)alertBtnAction:(UIButton *)sender {
    NSInteger tag = sender.tag - 2021;
    if (self.operateBlock) {
        self.operateBlock(tag, sender.titleLabel.text);
    }
    [self dismiss];
}

- (void)actionTap {
    [self dismiss];
}
#pragma mark - setter/getter

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"alert_close_24"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = @"";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _scrollView;
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.textColor = [OSSVThemesColors col_666666];
        _messageLabel.numberOfLines = 0;
        
        _messageLabel.textAlignment = NSTextAlignmentCenter;
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _messageLabel.textAlignment = NSTextAlignmentRight;
//        }
    }
    return _messageLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomView;
}



- (void)layoutButtons:(NSArray *)allTitleArr {
    
    UIButton *tempButton = nil;
    for (int i = 0 ; i<allTitleArr.count; i++) {
        
        //按钮
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.backgroundColor = [UIColor whiteColor];
        if (APP_TYPE == 3) {
            [actionBtn.titleLabel setFont:[UIFont vivaiaRegularFont:17]];
        } else {
            [actionBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        }
        [actionBtn setTitleColor:STLAlertBottomView_BtnTitleFormateNorColor forState:0];
        actionBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        actionBtn.layer.cornerRadius = 2.0;
        actionBtn.layer.masksToBounds = YES;

        [actionBtn addTarget:self action:@selector(alertBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setExclusiveTouch:YES];
        
        //按钮个数大于2个  上下排列，第一个背景黑色
        if (i == 0) {
            [actionBtn setTitleColor:STLAlertBottomView_BtnTitleFormateHighColor forState:0];
            [actionBtn setBackgroundImage:[STLAlertBottomView ok_imageWithColor:STLAlertBottomView_BtnBgFormateHighColor] forState:UIControlStateNormal];
        } else {
            [actionBtn setTitleColor:STLAlertBottomView_BtnTitleFormateNorColor forState:0];
            [actionBtn setBackgroundImage:[STLAlertBottomView ok_imageWithColor:[OSSVThemesColors stlWhiteColor]] forState:UIControlStateNormal];
            actionBtn.layer.borderColor = STLAlertBottomView_BtnBgFormateBorderColor.CGColor;
            actionBtn.layer.borderWidth = 1.0;
        }
        actionBtn.tag = 2021+i;
        [self.bottomView addSubview:actionBtn];
        
        //赋值按钮标题
        id btnTitleObject = allTitleArr[i];
        if ([btnTitleObject isKindOfClass:[NSString class]]) {
            
            [actionBtn setTitle:btnTitleObject forState:0];

            
        } else if([btnTitleObject isKindOfClass:[NSAttributedString class]]){
            actionBtn.titleLabel.numberOfLines = 0;
            actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [actionBtn setAttributedTitle:btnTitleObject forState:0];
        }
        
        //        //保存按钮
        //        [self.alertAllButtonArr addObject:actionBtn];
        
        
        
        
        if (tempButton) {
            [actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
                make.top.mas_equalTo(tempButton.mas_bottom).offset(8);
                make.height.mas_equalTo(@(44));
            }];
        } else {
            [actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
                make.top.mas_equalTo(self.bottomView.mas_top).offset(8);
                make.height.mas_equalTo(@(44));
            }];
        }
        tempButton = actionBtn;
    }
}

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

@end
