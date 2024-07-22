//
//  ZFMessageTipView.m
//  ZZZZZ
//
//  Created by YW on 2019/1/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMessageTipView.h"
#import <Masonry/Masonry.h>

@interface ZFMessageTipView ()

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ZFMessageTipView

BOOL ZFMessageTipEmptyString(id obj) {
    
    if (![obj isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (obj == nil || obj == NULL) {
        return YES;
    }
    if ([obj isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

- (instancetype)initMessage:(NSString *)message
                       font:(UIFont *)font
                  textColor:(UIColor *)textColor
            backgroundColor:(UIColor *)backgroundColor
                     corner:(CGFloat)corner {
    
    self = [super init];
    if (self) {
        
        if ([backgroundColor isKindOfClass:[UIColor class]]) {
            self.backgroundColor = backgroundColor;
        }
        
        if (corner > 0) {
            self.layer.cornerRadius = corner;
            self.layer.masksToBounds = YES;
        }
        
        if ([font isKindOfClass:[UIFont class]]) {
            self.messageLabel.font = font;
        }
        if ([textColor isKindOfClass:[UIColor class]]) {
            self.messageLabel.textColor = textColor;
        }
        
        if (!ZFMessageTipEmptyString(message)) {
            self.messageLabel.text = message;
        }
        [self addSubview:self.messageLabel];
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(20);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
        
    }
    return self;
}


- (void)showTime:(CGFloat)time completion:(void (^)(void))completion {
    self.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
        if (completion) {
            completion();
        }
    });

    
}
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}



@end
