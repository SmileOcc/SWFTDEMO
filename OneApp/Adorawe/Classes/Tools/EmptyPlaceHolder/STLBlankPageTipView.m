//
//  STLBlankPageTipView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLBlankPageTipView.h"
#import "UIButton+STLCategory.h"

#ifndef UIColorFromHex
#define UIColorFromHex(hexValue)            ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >> 8))/255.0 blue:((float)(hexValue & 0x0000FF))/255.0 alpha:1.0])
#endif

@interface STLBlankPageTipView ()
@property (nonatomic, copy) void(^block)(void);
@end


@implementation STLBlankPageTipView

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
+ (STLBlankPageTipView *)tipViewByFrame:(CGRect)frame
                            topDistance:(CGFloat)topDistance
                           moveOffsetY:(CGFloat)moveOffsetY
                              topImage:(UIImage *)image
                                 title:(id)title
                              subTitle:(id)subTitle
                           actionTitle:(id)buttonTitle
                           actionBlock:(void(^)(void))block
{
    STLBlankPageTipView *tipView = [[STLBlankPageTipView alloc] initWithFrame:frame
                                                                  topDistance:topDistance
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
                  topDistance:(CGFloat)topDistance
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
        CGFloat viewLeftMargin = 40;
        CGFloat maxWidth = tipViewWidth - viewLeftMargin *2;
        UIView *contenView = [[UIView alloc] init];
        contenView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        contenView.backgroundColor = [UIColor clearColor];
        [self addSubview:contenView];

        CGFloat contenViewMaxHeight = 0;

        //底部图片
        CGFloat imageSpace = 8;
        UIImageView *_tipImageView = nil;
        if (image) {
            _tipImageView = [[UIImageView alloc] initWithImage:image];
            _tipImageView.backgroundColor = [UIColor clearColor];
            _tipImageView.contentMode = UIViewContentModeScaleAspectFill;
            _tipImageView.clipsToBounds = YES;
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
            _tipLabel.font = [UIFont systemFontOfSize:14];
            _tipLabel.textColor = [OSSVThemesColors col_6C6C6C];
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
            _subTitleLabel.font = [UIFont systemFontOfSize:13];
            _subTitleLabel.textColor = [OSSVThemesColors col_6C6C6C];
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
            //contenViewMaxHeight = contenViewMaxHeight + 20;
        }
        
        //底部按钮
        if (buttonTitle) {
            UIButton *actionBtn = [[UIButton alloc] init];
            //actionBtn.layer.cornerRadius = 3;
            
            actionBtn.titleLabel.font = [UIFont stl_buttonFont: APP_TYPE == 3 ? 14 : 12];
            if (APP_TYPE != 3) {
                [actionBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:0];
                [actionBtn setBackgroundColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
                [actionBtn setBackgroundColor:[OSSVThemesColors col_0D0D0D:0.8] forState:UIControlStateHighlighted];
            }else{
                [actionBtn setTitleColor:[OSSVThemesColors stlBlackColor] forState:0];
                actionBtn.layer.borderColor = [OSSVThemesColors stlBlackColor].CGColor;
                actionBtn.layer.borderWidth = 2;
            }
           
            //actionBtn.titleLabel.numberOfLines = 0;
            //actionBtn.layer.cornerRadius = 3;
            //actionBtn.layer.masksToBounds = YES;
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
            //强制设置按钮宽度 为屏幕一半
            CGFloat btnW = tipViewWidth - viewLeftMargin*2;
            btnW = [UIScreen mainScreen].bounds.size.width / 2.0;
            
            CGFloat btnH = APP_TYPE == 3 ? 40 : 36;
            actionBtn.frame = CGRectMake((contenView.bounds.size.width-btnW)/2, contenViewMaxHeight, btnW, btnH);

            contenViewMaxHeight = CGRectGetMaxY(actionBtn.frame);
        }

        //设置contenView位置（只能上移距离）
        CGFloat topX = (frame.size.height-contenViewMaxHeight)/2;
        if (topDistance > 0) {
            topX = topDistance;
        } else {
            if (topX > moveOffsetY && moveOffsetY > 0) {
                topX -= moveOffsetY;
            }
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
