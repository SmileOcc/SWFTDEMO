//
//  ZFMyOrderListTopMessageView.m
//  ZZZZZ
//
//  Created by YW on 2018/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFMyOrderListTopMessageView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFMyOrderListTopMessageView()<ZFInitViewProtocol>

@property (nonatomic, strong) UILabel            *contentLabel;
@property (nonatomic, strong) UIButton           *eventButton;
@property (nonatomic, strong) UIButton           *closeButton;

@end

@implementation ZFMyOrderListTopMessageView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFC0xF2F2F2();
    [self addSubview:self.contentLabel];
    [self addSubview:self.eventButton];
    [self addSubview:self.closeButton];
}

- (void)zfAutoLayoutView {

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.width.mas_equalTo(40);
    }];
    
    [self.eventButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.closeButton.mas_leading);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
        make.width.mas_lessThanOrEqualTo(@80);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.top.mas_equalTo(self.mas_top).mas_offset(5);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-5);
        make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.eventButton.mas_leading).mas_offset(-12);
        make.height.mas_greaterThanOrEqualTo(@22);
    }];
    
    
    [self.eventButton setContentHuggingPriority:UILayoutPriorityRequired
                                           forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.eventButton setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                         forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - action
- (void)actionOpen:(UIButton *)sender {
    if (self.operateEventBlock) {
        self.operateEventBlock();
    }
}

- (void)actionClose {
    if (self.operateCloseBlock) {
        self.operateCloseBlock();
    }
}


#pragma mark - getter/setter

- (void)setIsAccountPage:(BOOL)isAccountPage {
    _isAccountPage = isAccountPage;
    if (isAccountPage) {
        self.backgroundColor = ZFCOLOR(232, 232, 232, 1);
        self.contentLabel.numberOfLines = 2;
        self.contentLabel.text = ZFLocalizedString(@"Account_notifications_tips", nil);
        [self.eventButton setTitle:ZFLocalizedString(@"Push_Enable", nil) forState:UIControlStateNormal];
    }
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = ColorHex_Alpha(0x666666, 1.0);
        _contentLabel.font = ZFFontSystemSize(12);
        _contentLabel.numberOfLines = 0;
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 4;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        _contentLabel.attributedText = [[NSAttributedString alloc] initWithString:ZFLocalizedString(@"Push_Order_Status_Delivery&_Shipping_Information", nil) attributes:attributes];;
    }
    return _contentLabel;
}

- (UIButton *)eventButton {
    if (!_eventButton) {
        _eventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventButton setTitle:ZFLocalizedString(@"Push_Open", nil) forState:UIControlStateNormal];
        _eventButton.titleLabel.font = ZFFontSystemSize(14);
        [_eventButton setTitleColor:ColorHex_Alpha(0x2D2D2D, 1.0) forState:UIControlStateNormal];
        _eventButton.layer.borderWidth = 1.0;
        _eventButton.layer.borderColor = ColorHex_Alpha(0x2D2D2D, 1.0).CGColor;
        _eventButton.layer.cornerRadius = 2;
        _eventButton.layer.masksToBounds = YES;
        [_eventButton setContentEdgeInsets:UIEdgeInsetsMake(10, 5, 10, 5)];
        [_eventButton addTarget:self action:@selector(actionOpen:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eventButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"size_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
