//
//  ZFConcaveArrowTipView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFConcaveArrowTipView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"

@interface ZFConcaveArrowTipView()

/** 箭头尖偏移位置*/
@property (nonatomic, assign) CGFloat      offset;
/** 箭头尖偏移方向*/
@property (nonatomic, assign) NSInteger    direct;
/** 箭头高度*/
@property (nonatomic, assign) CGFloat      arrowH;
/** 箭头宽度*/
@property (nonatomic, assign) CGFloat      arrowW;
/** 内容视图上下间隙值*/
@property (nonatomic, assign) CGFloat      topSpace;
/** 内容视图左右间隙值*/
@property (nonatomic, assign) CGFloat      leadSpace;

/**文案配置*/
@property (nonatomic, strong) UIColor      *textColor;
@property (nonatomic, strong) UIColor      *textBackgroundColor;
@property (nonatomic, assign) UIFont       *textFont;

@property (nonatomic, strong) UIColor      *bgColor;




//可扩充
@property (nonatomic, strong) UILabel      *defaultContentLabel;

@end

@implementation ZFConcaveArrowTipView


- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(ZFConcaveArrowTipDirect)direct
                           content:(NSString *)content {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.shadowColor = ColorHex_Alpha(0x000000, 0.2).CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
        self.offset = offset;
        self.direct = direct;
        self.arrowW = 16.0;
        self.arrowH = 8.0;
        self.topSpace = 12;
        self.leadSpace = 18;
        
        self.textFont = ZFFontSystemSize(14);
        self.textColor =  ColorHex_Alpha(0x2D2D2D, 1.0);
        self.textBackgroundColor =  [UIColor clearColor];
        self.bgColor = [UIColor whiteColor];

        [self showDefaultContent:content updateConstraints:YES];
    }
    return self;
}

- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(ZFConcaveArrowTipDirect)direct
                           content:(NSString *)content
                        arrowWidth:(CGFloat)arrowWidth
                       arrowHeight:(CGFloat)arrowHeight
                          topSpace:(CGFloat)topSpace
                         leadSpace:(CGFloat)leadSpace
                          textFont:(UIFont *)textFont
                         textColor:(UIColor *)textColor
               textBackgroundColor:(UIColor *)textBackgroundColor
                   backgroundColor:(UIColor *)backgroundColr {
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.shadowColor = ColorHex_Alpha(0x000000, 0.2).CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
        self.offset = offset;
        self.direct = direct;
        self.arrowW = arrowWidth >= 0 ? arrowWidth : 16.0;
        self.arrowH = arrowHeight >= 0 ? arrowHeight : 8.0;
        self.topSpace = topSpace >= 0 ? topSpace : 12;
        self.leadSpace = leadSpace >= 0 ? leadSpace : 18;
        
        self.textFont = textFont ? textFont : ZFFontSystemSize(14);
        self.textColor = textColor ? textColor : ColorHex_Alpha(0x2D2D2D, 1.0);
        self.textBackgroundColor = textBackgroundColor ? textBackgroundColor : [UIColor clearColor];
  
        self.bgColor = backgroundColr ? backgroundColr : [UIColor whiteColor];
        [self showDefaultContent:content updateConstraints:YES];
    }
    return self;
}


- (void)showDefaultContent:(NSString *)content updateConstraints:(BOOL)update{
    
    if (!ZFIsEmptyString(content)) {
        self.defaultContentLabel.text = ZFToString(content);
    } else {
        if (content == nil) { //不处理
            
        } else if (_defaultContentLabel) {
            self.defaultContentLabel.text = @"";
            self.hidden = YES;
        }
    }
    if (update) {
        [self showContentViewConstraints:self.defaultContentLabel];
    }
}


- (void)showContentViewConstraints:(UIView *)showView {
    
    //若显示过默认内容视图，先移除
    if (_defaultContentLabel.superview) {
        [self.defaultContentLabel removeFromSuperview];
    }
    
    if (!showView) {
        return;
    }
    
    CGFloat tempTop = self.topSpace;
    CGFloat tempBottom = self.topSpace;
    CGFloat tempLeading = self.leadSpace;
    CGFloat tempTrailing = self.leadSpace;
    CGFloat tempArrowH = self.arrowH;
    
    
    if (showView.superview) {
        if (showView.superview != self) {
            [showView removeFromSuperview];
            [self addSubview:showView];
            
            [showView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(tempArrowH + tempTop);
                make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
            }];
        }
    } else {
        [self addSubview:showView];
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(tempArrowH + tempTop);
            make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
        }];
    }
    
    
    if (self.direct == ZFConcaveArrowTipDirectUpLeft || self.direct == ZFConcaveArrowTipDirectUpRight || self.direct == ZFConcaveArrowTipDirectUpNoOffset) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(tempArrowH + tempTop);
            make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
        }];
        
    } else if (self.direct == ZFConcaveArrowTipDirectDownLeft || self.direct == ZFConcaveArrowTipDirectDownRight || self.direct == ZFConcaveArrowTipDirectDownNoOffset) {
        
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(tempTop);
            make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-(tempArrowH + tempBottom));
        }];
        
    } else if (self.direct == ZFConcaveArrowTipDirectLeftUp || self.direct == ZFConcaveArrowTipDirectLeftDown || self.direct == ZFConcaveArrowTipDirectLeftNoOffset) {
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(tempTop);
                make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-(tempTrailing + tempArrowH));
                make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
            }];
        } else {
            [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(tempTop);
                make.leading.mas_equalTo(self.mas_leading).offset(tempLeading + tempArrowH);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
            }];
        }
        
    } else if (self.direct == ZFConcaveArrowTipDirectRightUp || self.direct == ZFConcaveArrowTipDirectRightDown || self.direct == ZFConcaveArrowTipDirectRightNoOffset) {
        
         if ([SystemConfigUtils isRightToLeftShow]) {
             
             [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
                 make.top.mas_equalTo(self.mas_top).offset(tempTop);
                 make.leading.mas_equalTo(self.mas_leading).offset(tempLeading + tempArrowH);
                 make.trailing.mas_equalTo(self.mas_trailing).offset(-tempTrailing);
                 make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
             }];
             
         } else {
             [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
                 make.top.mas_equalTo(self.mas_top).offset(tempTop);
                 make.leading.mas_equalTo(self.mas_leading).offset(tempLeading);
                 make.trailing.mas_equalTo(self.mas_trailing).offset(-(tempTrailing + tempArrowH));
                 make.bottom.mas_equalTo(self.mas_bottom).offset(-tempBottom);
             }];
         }
    }
}

- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFConcaveArrowTipDirect)direct
                      cotent:(NSString *)content {
    
    if (self.offset != offset || self.direct != direct) {
        self.offset = offset;
        self.direct = direct;
        [self showDefaultContent:content updateConstraints:YES];
    } else {
        [self showDefaultContent:content updateConstraints:NO];
    }
}


#pragma mark - 隐藏
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion{
    if (time < 0) {
        time = 3;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.hidden = YES;
        if (completion) {
            completion();
        }
    });
}

- (void)hideView {
    self.hidden = YES;
}


#pragma mark -
- (UILabel *)defaultContentLabel {
    if (!_defaultContentLabel) {
        _defaultContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _defaultContentLabel.font = self.textFont;
        _defaultContentLabel.textColor = self.textColor;
        _defaultContentLabel.backgroundColor = self.textBackgroundColor;
        _defaultContentLabel.numberOfLines = 0;
    }
    return _defaultContentLabel;
}


- (void)drawRect:(CGRect)rect {
    CGRect frame = rect;
    
    if (!self.bgColor) {
        self.bgColor = [UIColor whiteColor];
    }
    CGFloat frameWidth = CGRectGetWidth(frame);
    CGFloat frameHeight = CGRectGetHeight(frame);
    //箭头宽、高
    CGFloat arrowW = self.arrowW;
    CGFloat arrowH = self.arrowH;
    
    CGFloat moveDirect = self.direct;
    CGFloat moveOffset = 0.0;

    //FIXME: occ Bug 1101 待优化，最大值，限制等
    if (moveDirect == ZFConcaveArrowTipDirectUpNoOffset
        || moveDirect == ZFConcaveArrowTipDirectLeftNoOffset
        || moveDirect == ZFConcaveArrowTipDirectDownNoOffset
        || moveDirect == ZFConcaveArrowTipDirectRightNoOffset) {
        
        if (moveDirect == ZFConcaveArrowTipDirectUpNoOffset || moveDirect == ZFConcaveArrowTipDirectDownNoOffset) {
            arrowW = frameWidth;
            //arrowH = arrowW * self.arrowH / self.arrowW;
        } else if (moveDirect == ZFConcaveArrowTipDirectLeftNoOffset || moveDirect == ZFConcaveArrowTipDirectRightNoOffset) {
            arrowW = frameHeight;
            //arrowH = arrowW * self.arrowH / self.arrowW;
        }
        moveOffset = arrowW / 2.0;
        self.offset = -1;

    } else {
        
        if (self.offset >= 0) {
            moveOffset = self.offset;
        } else {
            //确定方向，居中处理
            if (moveDirect == ZFConcaveArrowTipDirectUpRight || moveDirect == ZFConcaveArrowTipDirectUpLeft
                || moveDirect == ZFConcaveArrowTipDirectDownLeft || moveDirect == ZFConcaveArrowTipDirectDownRight) {
                moveOffset = frameWidth / 2.0;
            } else {
                moveOffset = frameHeight / 2.0;
            }
        }
    }
    
    // 若要偏移，最少是箭头宽的一半
    if (moveOffset < arrowW / 2.0) {
        moveOffset = arrowW / 2.0;
    }
    
    
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.0] set];
    
    if (moveDirect == ZFConcaveArrowTipDirectUpRight || moveDirect == ZFConcaveArrowTipDirectUpLeft || moveDirect == ZFConcaveArrowTipDirectUpNoOffset) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0);
        if (moveDirect == ZFConcaveArrowTipDirectUpLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, 0);
            CGContextAddLineToPoint(contextRef, moveOffset, arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, 0);
            CGContextAddLineToPoint(contextRef, frameWidth, 0);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (arrowW / 2.0 + moveOffset), 0);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), 0);
            CGContextAddLineToPoint(contextRef, frameWidth, 0);
        }
        
        CGContextAddLineToPoint(contextRef, frame.size.width, frame.size.height);
        CGContextAddLineToPoint(contextRef, 0.0, frame.size.height);
        CGContextAddLineToPoint(contextRef, 0.0, arrowH);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, self.bgColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == ZFConcaveArrowTipDirectDownLeft || moveDirect == ZFConcaveArrowTipDirectDownRight || moveDirect == ZFConcaveArrowTipDirectDownNoOffset) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0.0);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        
        
        if (moveDirect == ZFConcaveArrowTipDirectDownLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, frameHeight);
            CGContextAddLineToPoint(contextRef, moveOffset, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, frameHeight);
            CGContextAddLineToPoint(contextRef, 0, frameHeight);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), frameHeight);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset + arrowW / 2.0), frameHeight);
            CGContextAddLineToPoint(contextRef, 0, frameHeight);
        }
        
        CGContextAddLineToPoint(contextRef, 0.0, 0.0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, self.bgColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
    }
    
    else if (moveDirect == ZFConcaveArrowTipDirectLeftUp || moveDirect == ZFConcaveArrowTipDirectLeftDown || moveDirect == ZFConcaveArrowTipDirectLeftNoOffset) {
        
        CGContextMoveToPoint(contextRef, 0, 0.0);
        
        if (moveDirect == ZFConcaveArrowTipDirectLeftUp) {
            CGContextAddLineToPoint(contextRef, 0, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset);
            CGContextAddLineToPoint(contextRef, 0, moveOffset + arrowW / 2.0);
            
        } else {
            CGContextAddLineToPoint(contextRef, 0, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, 0, frameHeight -(moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, 0, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        CGContextAddLineToPoint(contextRef, 0, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, self.bgColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == ZFConcaveArrowTipDirectRightUp || moveDirect == ZFConcaveArrowTipDirectRightDown || moveDirect == ZFConcaveArrowTipDirectRightNoOffset) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0.0);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        
        if (moveDirect == ZFConcaveArrowTipDirectRightUp) {
            CGContextAddLineToPoint(contextRef, frameWidth, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth, moveOffset + arrowW / 2.0);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - (moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, self.bgColor.CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    
}

@end
