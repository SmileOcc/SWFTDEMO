//
//  ZFFullLiveLiveMessagePushView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveLiveMessagePushView.h"
#import "Masonry.h"
#import "NSString+Extended.h"
#import "YWCFunctionTool.h"
@interface ZFFullLiveLiveMessagePushView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *contentImageView;

@end

@implementation ZFFullLiveLiveMessagePushView

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        [self setupView];
        [self layout];
        
        self.contentImageView.backgroundColor = ZFRandomColor();
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.contentView];
    [self addSubview:self.contentImageView];
    [self addSubview:self.messageLabel];
    [self addSubview:self.imageView];
}

- (void)layout {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-30);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.top.mas_equalTo(self.mas_top).offset(5);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentImageView.mas_trailing).offset(-15);
        make.top.mas_equalTo(self.contentImageView.mas_top).offset(-5);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.equalTo(self.mas_leading).offset(12);
        make.trailing.offset(-50);
        make.top.mas_equalTo(self.mas_top).offset(7);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-2);
        make.height.mas_greaterThanOrEqualTo(28);
    }];
    
}

- (void)configWithMessageInfo:(ZFZegoMessageInfo *)messageInfo {
    
    switch (messageInfo.infoType) {
        case ZegoMessageInfoTypeCart:
            self.imageView.image = [UIImage imageNamed:@"live_message_cart"];
            self.contentImageView.image = [UIImage imageNamed:@"live_message_cart_bg"];
            break;

        case ZegoMessageInfoTypeOrder:
            self.imageView.image = [UIImage imageNamed:@"live_pay_success"];
            self.contentImageView.image = [UIImage imageNamed:@"live_message_pay_bg"];

            break;

        case ZegoMessageInfoTypePay:
            self.imageView.image = [UIImage imageNamed:@"live_pay_success"];
            self.contentImageView.image = [UIImage imageNamed:@"live_message_pay_bg"];

            break;
            
        default:
            break;
    }
    self.messageLabel.text = [NSString stringWithFormat:@"%@ %@",messageInfo.nickname,messageInfo.content];
}


- (CGFloat)configContentHeight {
    CGSize stockTipsSize = [ZFToString(self.messageLabel.text) textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(208, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:nil];
    CGFloat h = stockTipsSize.height < 28 ? 28 : 40;
    self.currentH = (h + 4);
    return self.currentH;
}

#pragma mark - getter/setter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:14.0f];
        _messageLabel.numberOfLines = 2;
    }
    return _messageLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentImageView.layer.cornerRadius = 14;
        _contentImageView.layer.masksToBounds = YES;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _contentImageView;
}

@end
