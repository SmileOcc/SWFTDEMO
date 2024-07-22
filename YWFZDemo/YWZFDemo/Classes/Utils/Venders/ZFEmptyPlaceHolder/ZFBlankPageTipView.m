//
//  OKRequestTipBgView.m
//  CommonFrameWork
//
//  Created by YW on 2016/11/24.
//  Copyright © 2016年 okdeer. All rights reserved.
//

#import "ZFBlankPageTipView.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"

#ifndef UIColorFromHex
#define UIColorFromHex(hexValue)            ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

@interface ZFBlankPageTipView ()
@property (nonatomic, copy) void(^block)(void);
@end

@implementation ZFBlankPageTipView

/**
 返回一个提示空白view
 
 @param frame       提示View大小
 @param topImage    图片名字
 @param title       提示标题
 @param subTitle    提示副标题
 @param title       按钮标题
 @param block       点击按钮回调Block
 @return 提示空白view
 */
+ (ZFBlankPageTipView *)tipViewByFrame:(CGRect)frame
                           moveOffsetY:(CGFloat)moveOffsetY
                              topImage:(UIImage *)image
                                 title:(id)title
                              subTitle:(id)subTitle
                           actionTitle:(id)buttonTitle
                           actionBlock:(void(^)(void))block
{
    ZFBlankPageTipView *tipView = [[ZFBlankPageTipView alloc] initWithFrame:frame
                                                                moveOffsetY:moveOffsetY
                                                                   topImage:image
                                                                      title:title
                                                                   subTitle:subTitle
                                                                actionTitle:buttonTitle
                                                                actionBlock:block];
    tipView.tag = kRequestTipViewTag;
    tipView.backgroundColor = [UIColor clearColor];
    return tipView;
}

- (instancetype)initWithFrame:(CGRect)frame
                  moveOffsetY:(CGFloat)moveOffsetY
                     topImage:(UIImage *)image
                        title:(id)title
                     subTitle:(id)subTitle
                  actionTitle:(id)buttonTitle
                  actionBlock:(void(^)(void))block
{
    self = [super initWithFrame:frame];
    if(self){
        self.block = block;

        CGFloat tipViewWidth = frame.size.width < 50 ? [UIScreen mainScreen].bounds.size.width : frame.size.width;
        CGFloat viewLeftMargin = 28;
        CGFloat maxWidth = tipViewWidth - viewLeftMargin *2;
        UIView *contenView = [[UIView alloc] init];
        contenView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        contenView.backgroundColor = [UIColor clearColor];
        [self addSubview:contenView];

        CGFloat contenViewMaxHeight = 0;

        //顶部图片
        CGFloat imageSpace = 36;
        UIImageView *_tipImageView = nil;
        if (image) {
            _tipImageView = [[UIImageView alloc] initWithImage:image];
            _tipImageView.backgroundColor = [UIColor clearColor];
            _tipImageView.contentMode = UIViewContentModeScaleAspectFill;
            [contenView addSubview:_tipImageView];
            _tipImageView.frame = CGRectMake((frame.size.width-image.size.width)/2, 0, image.size.width, image.size.height);

            contenViewMaxHeight = CGRectGetMaxY(_tipImageView.frame)+imageSpace;
        }

        //标题
        CGFloat titleSpace = 16;
        UILabel *_tipLabel = nil;
        if (title) {
            _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 20)];
            _tipLabel.backgroundColor = [UIColor clearColor];
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.adjustsFontSizeToFitWidth = YES;
            _tipLabel.preferredMaxLayoutWidth = maxWidth;
            [contenView addSubview:_tipLabel];

            if ([title isKindOfClass:[NSString class]]) {
                _tipLabel.text = title;
            } else if ([title isKindOfClass:[NSAttributedString class]]) {
                _tipLabel.attributedText = title;
            }
            [_tipLabel sizeToFit];
            CGFloat tipLabelWidth = MIN(maxWidth, _tipLabel.bounds.size.width);
            _tipLabel.frame = CGRectMake((frame.size.width-tipLabelWidth)/2, contenViewMaxHeight,
                                         tipLabelWidth, _tipLabel.bounds.size.height);

            contenViewMaxHeight = CGRectGetMaxY(_tipLabel.frame)+titleSpace;
        }
        
        //副标题
        CGFloat subTitleSpace = 36;
        UILabel *_subTitleLabel = nil;
        if (subTitle) {
            _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxWidth, 20)];
            _subTitleLabel.backgroundColor = [UIColor clearColor];
            _subTitleLabel.font = [UIFont systemFontOfSize:14];
            _subTitleLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
            _subTitleLabel.textAlignment = NSTextAlignmentCenter;
            _subTitleLabel.numberOfLines = 0;
            _subTitleLabel.adjustsFontSizeToFitWidth = YES;
            _subTitleLabel.preferredMaxLayoutWidth = maxWidth;
            [contenView addSubview:_subTitleLabel];
            
            if ([title isKindOfClass:[NSString class]]) {
                _subTitleLabel.text = subTitle;
            } else if ([title isKindOfClass:[NSAttributedString class]]) {
                _subTitleLabel.attributedText = subTitle;
            }
            [_subTitleLabel sizeToFit];
            
            CGFloat subTitleWidth = MIN(maxWidth, _subTitleLabel.bounds.size.width);
            _subTitleLabel.frame = CGRectMake((frame.size.width-subTitleWidth)/2, contenViewMaxHeight,
                                         subTitleWidth, _subTitleLabel.bounds.size.height);
            
            contenViewMaxHeight = CGRectGetMaxY(_subTitleLabel.frame)+subTitleSpace;
        }  else {
            contenViewMaxHeight = contenViewMaxHeight + 20;
        }
        
        //底部按钮
        if (buttonTitle) {
            UIButton *actionBtn = [[UIButton alloc] init];
            //actionBtn.layer.cornerRadius = 3;
            [actionBtn setTitleColor:ZFCOLOR_WHITE forState:0];
            actionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            //actionBtn.backgroundColor = ZFCThemeColor();
            [actionBtn setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [actionBtn setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
            actionBtn.titleLabel.numberOfLines = 0;
            actionBtn.layer.cornerRadius = 3;
            actionBtn.layer.masksToBounds = YES;
            [actionBtn addTarget:self action:@selector(buttonAction) forControlEvents:(UIControlEventTouchUpInside)];
            [contenView addSubview:actionBtn];
            self.actionBtn = actionBtn;

            if ([buttonTitle isKindOfClass:[NSString class]]) {
                [actionBtn setTitle:buttonTitle forState:0];
            } else if ([buttonTitle isKindOfClass:[NSAttributedString class]]) {
                [actionBtn setAttributedTitle:buttonTitle forState:0];
            }
            [actionBtn sizeToFit];

            //设置frame
            CGFloat btnW = tipViewWidth - viewLeftMargin*2;
            CGFloat btnH = 40;
            actionBtn.frame = CGRectMake((contenView.bounds.size.width-btnW)/2, contenViewMaxHeight, btnW, btnH);

            contenViewMaxHeight = CGRectGetMaxY(actionBtn.frame);
        }

        //设置contenView位置（只能上移距离）
        CGFloat topX = (frame.size.height-contenViewMaxHeight)/2;
        if (topX > moveOffsetY && moveOffsetY > 0) {
            topX -= moveOffsetY;
        }
        contenView.frame = CGRectMake(0,topX,
                                      frame.size.width,
                                      contenViewMaxHeight);
    }
    return self;
}

/**
 * 提示按钮点击事件
 */
- (void)buttonAction
{
    if (self.block) {
        self.block();
    }
}

@end

