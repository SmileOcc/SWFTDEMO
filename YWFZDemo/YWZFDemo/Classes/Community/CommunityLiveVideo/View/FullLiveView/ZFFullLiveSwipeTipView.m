//
//  ZFFullLiveSwipeTipView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveSwipeTipView.h"
#import "ZFLocalizationString.h"
@implementation ZFFullLiveSwipeTipView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = ZFC0x000000_A(0.5);
        
        [self addSubview:self.contentView];
        [self addSubview:self.imageView];
        [self addSubview:self.messageLabel];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(42);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-42);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
        }];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.top.mas_equalTo(self.imageView.mas_top).offset(6);
        }];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPan:)];
        [self addGestureRecognizer:pan];
    }
    
    return self;
}

- (void)actionPan:(UIPanGestureRecognizer *)panGesture {
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [panGesture translationInView:self];
        
        CGFloat absX = fabs(point.x);
        CGFloat absY = fabs(point.y);

        // 设置滑动有效距离
        if (MAX(absX, absY) < 40) {
            return;
        }

        if (absX > absY ) {
            panGesture.enabled = NO;
            self.hidden = YES;
            if (self.superview) {
                [self removeFromSuperview];
            }

        }
    }
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"live_clear_tip"];
    }
    return _imageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = ZFC0xFFFFFF();
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = ZFLocalizedString(@"Live_Swipe_right_clear_left_recover", nil);
    }
    return _messageLabel;
}
@end
