//
//  ZFMyOrderListStatusHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListStatusHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFCountDownView.h"
#import "ZFTimerManager.h"

@interface ZFMyOrderListStatusHeaderView() <ZFInitViewProtocol>

@property (nonatomic, strong) UIView            *tagIconView;
@property (nonatomic, strong) UILabel           *statusLabel;
//V4.0列表不显示订单号
//@property (nonatomic, strong) UILabel           *orderNumLabel;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@property (nonatomic, strong) ZFCountDownView   *countDownView;
@end

@implementation ZFMyOrderListStatusHeaderView
#pragma mark - init methods
- (void)dealloc
{
//    NSString *key = [NSString stringWithFormat:@"%@%@", self.model.order_id, @"OrderListCountTime"];
//    [[ZFTimerManager shareInstance] stopTimer:key];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        @weakify(self);
        self.contentView.exclusiveTouch = YES;
        [self.contentView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.myOrderListEnterDetailCompletionHandler) {
                self.myOrderListEnterDetailCompletionHandler();
            }
        }];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.tagIconView];
    [self.contentView addSubview:self.statusLabel];
//    [self.contentView addSubview:self.orderNumLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.countDownView];
}

- (void)zfAutoLayoutView {
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.height.mas_equalTo(18);
    }];
    
    [self.tagIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.size.mas_equalTo(CGSizeMake(3, 15));
        make.centerY.mas_equalTo(self.statusLabel);
    }];
    
//    [self.orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.statusLabel.mas_leading);
//        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(10);
//        make.height.mas_equalTo(20);
//    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).mas_offset(3);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    NSString *key = [NSString stringWithFormat:@"%@%@", self.model.order_id, @"OrderListCountTime"];
    [[ZFTimerManager shareInstance] stopTimer:key];
}

#pragma mark - setter
- (void)setModel:(MyOrdersModel *)model {
    _model = model;
    self.statusLabel.text = _model.order_status_str;
//    self.orderNumLabel.text = [NSString stringWithFormat:@"%@: %@", ZFLocalizedString(@"MyOrders_Cell_Order",nil), _model.order_sn];
    
    self.countDownView.hidden = YES;
    if ([_model.pay_id isEqualToString:@"Cod"]) {
        self.statusLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        self.tagIconView.backgroundColor = ZFCOLOR(45, 45, 45, 1.f);
    }else{
        if ([_model.order_status integerValue] == 0) {  // 显示 payNow
            self.statusLabel.textColor = ZFC0xFE5269();
            self.tagIconView.backgroundColor = ZFC0xFE5269();
            self.countDownView.hidden = NO;
            NSString *key = [NSString stringWithFormat:@"%@%@", model.order_id, @"OrderListCountTime"];
            if (_model.pay_left_time.integerValue > 0) {
                [[ZFTimerManager shareInstance] startTimer:key];
                YWLog(@"orderListCountDown %@ - %ld",self.model.order_id, self.model.pay_left_time.integerValue);
                [self.countDownView startTimerWithStamp:_model.pay_left_time timerKey:key completeBlock:^{
                }];
            } else {
                [[ZFTimerManager shareInstance] stopTimer:key];
                self.countDownView.hidden = YES;
            }
        }else if ([_model.order_status integerValue] == 11) {  // Cancel
            self.statusLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(153, 153, 153, 1.f);
        }else { // 显示 物流追踪
            self.statusLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(45, 45, 45, 1.f);
        }
    }
}

#pragma mark - getter
- (UIView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [[UIView alloc] initWithFrame:CGRectZero];
        _tagIconView.backgroundColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _tagIconView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _statusLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _statusLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _statusLabel;
}

//- (UILabel *)orderNumLabel {
//    if (!_orderNumLabel) {
//        _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _orderNumLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
//        _orderNumLabel.font = [UIFont systemFontOfSize:14.0];
//        _orderNumLabel.backgroundColor = ZFCOLOR_WHITE;
//    }
//    return _orderNumLabel;
//}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"account_arrow"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

-(ZFCountDownView *)countDownView
{
    if (!_countDownView) {
        _countDownView = ({
            ZFCountDownView *countDown = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:20 showDay:YES];
            countDown.timerBackgroundColor = [UIColor clearColor];
            countDown.timerTextColor = [UIColor whiteColor];
            countDown.timerDotColor = [UIColor blackColor];
            countDown.timerTextBackgroundColor = [UIColor blackColor];
            countDown.timerCircleRadius = 4;
            countDown;
        });
    }
    return _countDownView;
}

@end
