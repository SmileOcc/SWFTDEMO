//
//  ZFTitleArrowTipView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFTitleArrowTipView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFTitleArrowTipView()

@property (nonatomic, assign) CGFloat      offset;
@property (nonatomic, assign) NSInteger    direct;
@property (nonatomic, assign) CGFloat      arrowH;
@property (nonatomic, assign) CGFloat      arrowW;

//可扩充
@property (nonatomic, strong) UILabel      *defaultContentLabel;

@end

@implementation ZFTitleArrowTipView

+ (CGRect)sourceViewFrameToWindow:(UIView *)sourceView {
    if (sourceView.superview) {
        return [sourceView.superview convertRect:sourceView.frame toView:WINDOW];
    }
    return CGRectZero;
}

- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(ZFTitleArrowTipDirect)direct
                           content:(NSString *)content{
    
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
        
        [self showDefaultContent:content updateConstraints:YES];
        
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowColor = ColorHex_Alpha(0x000000, 0.2).CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
        self.arrowW = 16.0;
        self.arrowH = 8.0;
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
    if (showView.superview) {
        if (showView.superview != self) {
            [showView removeFromSuperview];
            [self addSubview:showView];
            
            [showView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(self.arrowH + 12);
                make.leading.mas_equalTo(self.mas_leading).offset(18);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-18);
                make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
            }];
        }
    } else {
        [self addSubview:showView];
        [showView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.arrowH + 12);
            make.leading.mas_equalTo(self.mas_leading).offset(18);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-18);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        }];
    }
    
    
    if (self.direct == ZFTitleArrowTipDirectUpLeft || self.direct == ZFTitleArrowTipDirectUpRight) {

        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(self.arrowH + 12);
            make.leading.mas_equalTo(self.mas_leading).offset(18);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-18);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        }];

    } else if (self.direct == ZFTitleArrowTipDirectDownLeft || self.direct == ZFTitleArrowTipDirectDownRight) {
    
        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.leading.mas_equalTo(self.mas_leading).offset(18);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-18);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-(self.arrowH + 12));
        }];
        
    } else if (self.direct == ZFTitleArrowTipDirectLeftUp || self.direct == ZFTitleArrowTipDirectLeftDown) {

        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.leading.mas_equalTo(self.mas_leading).offset(18 + self.arrowH);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-18);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        }];
    } else if (self.direct == ZFTitleArrowTipDirectRightUp || self.direct == ZFTitleArrowTipDirectRightDown) {

        [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.leading.mas_equalTo(self.mas_leading).offset(18);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-(18 + self.arrowH));
            make.bottom.mas_equalTo(self.mas_bottom).offset(-12);
        }];
    }
}


#pragma mark - 更新
- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFTitleArrowTipDirect)direct
                      cotent:(NSString *)content{
    
    if (self.offset != offset || self.direct != direct) {
        self.offset = offset;
        self.direct = direct;
        [self showDefaultContent:content updateConstraints:YES];
    } else {
        [self showDefaultContent:content updateConstraints:NO];
    }
}

- (void)updateTipArrowOffset:(CGFloat)offset
                      direct:(ZFTitleArrowTipDirect)direct
                 contentView:(UIView *)contentView {
    
    if (contentView) {
        self.offset = offset;
        self.direct = direct;
        [self showContentViewConstraints:contentView];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
    } else {
        self.hidden = YES;
    }
}

#pragma mark - 隐藏
- (void)hideViewWithTime:(NSInteger)time complectBlock:(void (^)(void))completion{
    if (time < 0) {
        time = 3;
    }
//    CGRect frame = self.frame;
//    frame.size.height = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.25 animations:^{
//            self.frame = frame;
//            [self layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            self.hidden = YES;
//        }];
        
        self.hidden = YES;
        if (completion) {
            completion();
        }
    });
}

- (void)hideView {
    self.hidden = YES;
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark -
- (UILabel *)defaultContentLabel {
    if (!_defaultContentLabel) {
        _defaultContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _defaultContentLabel.font = ZFFontSystemSize(14);
        _defaultContentLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        _defaultContentLabel.numberOfLines = 0;
    }
    return _defaultContentLabel;
}


- (void)drawRect:(CGRect)rect {
    CGRect frame = rect;
    
    CGFloat frameWidth = CGRectGetWidth(frame);
    CGFloat frameHeight = CGRectGetHeight(frame);
    //箭头宽、高
    CGFloat arrowW = self.arrowW;
    CGFloat arrowH = self.arrowH;
    //FIXME: occ Bug 1101 完善待
    CGFloat arcR = 4;
    
    CGFloat moveOffset = 0.0;
    CGFloat moveDirect = self.direct;
    if (self.offset >= 0) {
        moveOffset = self.offset;
    } else {
        if (moveDirect == ZFTitleArrowTipDirectUpRight || moveDirect == ZFTitleArrowTipDirectUpLeft
            || moveDirect == ZFTitleArrowTipDirectDownLeft || moveDirect == ZFTitleArrowTipDirectDownRight) {
            moveOffset = frameWidth / 2.0;
        } else {
            moveOffset = frameHeight / 2.0;
        }
    }
    if (moveOffset < arrowW / 2.0) {
        moveOffset = arrowW / 2.0;
    }

    // 设置最新圆角
    if ((moveOffset - arrowW / 2.0) < arcR) {
        arcR = moveOffset - arrowW / 2.0;
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.0] set];
    
    if (moveDirect == ZFTitleArrowTipDirectUpRight || moveDirect == ZFTitleArrowTipDirectUpLeft) {
        
        CGContextMoveToPoint(contextRef, 0.0, arrowH + arcR);

        //弧线
        CGContextAddArcToPoint(contextRef, 0, arrowH, arcR, arrowH, arcR);
        
        if (moveDirect == ZFTitleArrowTipDirectUpLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, arrowH);
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (arrowW / 2.0 + moveOffset), arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, 0.0);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, arrowH, frameWidth, arrowH + arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight, frameWidth - arcR, frameHeight, arcR);
        CGContextAddLineToPoint(contextRef, arcR, frameHeight);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight, 0, frameHeight - arcR, arcR);
        CGContextAddLineToPoint(contextRef, 0.0, arrowH + arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
        
    }
    
    else if (moveDirect == ZFTitleArrowTipDirectDownLeft || moveDirect == ZFTitleArrowTipDirectDownRight) {
        
        CGContextMoveToPoint(contextRef, 0.0, arcR);
        //弧线
        CGContextAddArcToPoint(contextRef, 0, 0, arcR, 0, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth - arcR, 0);
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, 0, frameWidth, arcR, arcR);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - arrowH - arcR);
        
        //弧线
        CGContextAddArcToPoint(contextRef, frameWidth, frameHeight - arrowH, frameWidth - arcR, frameHeight - arrowH, arcR);
        

        if (moveDirect == ZFTitleArrowTipDirectDownLeft) {
            CGContextAddLineToPoint(contextRef, moveOffset + arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, moveOffset - arrowW / 2.0, frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
            
        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset - arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, frameWidth -  moveOffset, frameHeight);
            CGContextAddLineToPoint(contextRef, frameWidth - (moveOffset + arrowW / 2.0), frameHeight - arrowH);
            CGContextAddLineToPoint(contextRef, arcR, frameHeight - arrowH);
        }
        
        //弧线
        CGContextAddArcToPoint(contextRef, 0, frameHeight - arrowH, 0, frameHeight - arrowH - arcR, arcR);
        
        CGContextAddLineToPoint(contextRef, 0.0, arcR);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);
    }
    
    else if (moveDirect == ZFTitleArrowTipDirectLeftUp || moveDirect == ZFTitleArrowTipDirectLeftDown) {
        
        CGContextMoveToPoint(contextRef, arrowH, 0.0);
        
        if (moveDirect == ZFTitleArrowTipDirectLeftUp) {
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, 0, moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, moveOffset + arrowW / 2.0);
            
        } else {
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, 0, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, arrowH, frameHeight -(moveOffset - arrowW / 2.0));
        }

        CGContextAddLineToPoint(contextRef, arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, frameHeight);
        CGContextAddLineToPoint(contextRef, frameWidth, 0);
        CGContextAddLineToPoint(contextRef, arrowH, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);

    }
    
    else if (moveDirect == ZFTitleArrowTipDirectRightUp || moveDirect == ZFTitleArrowTipDirectRightDown) {
        
        CGContextMoveToPoint(contextRef, 0.0, 0.0);
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, 0);

        if (moveDirect == ZFTitleArrowTipDirectRightUp) {
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset - arrowW / 2.0);
            CGContextAddLineToPoint(contextRef, frameWidth, moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, moveOffset + arrowW / 2.0);

        } else {
            
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset + arrowW / 2.0));
            CGContextAddLineToPoint(contextRef, frameWidth, frameHeight - moveOffset);
            CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight - (moveOffset - arrowW / 2.0));
        }
        
        CGContextAddLineToPoint(contextRef, frameWidth - arrowH, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, frameHeight);
        CGContextAddLineToPoint(contextRef, 0, 0);
        CGContextClosePath(contextRef);
        CGContextSetFillColorWithColor(contextRef, [UIColor whiteColor].CGColor);
        CGContextDrawPath(contextRef, kCGPathFill);

    }
    
   
}

@end
