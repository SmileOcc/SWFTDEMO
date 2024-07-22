//
//  ZFOfflineOrderInfoCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOfflineOrderInfoCCell.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFOrderPayTools.h"
#import <Masonry/Masonry.h>

#pragma mark - subview

@interface ZFCCellHeadInfo : UIView

@property (nonatomic, strong) UIImageView *orderImage;
@property (nonatomic, strong) UIImageView *payImage;
@property (nonatomic, strong) UIImageView *shipImage;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UILabel *orderLabel;
@property (nonatomic, strong) UILabel *payLabel;
@property (nonatomic, strong) UILabel *shipLabel;

@end

@implementation ZFCCellHeadInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.progressView];
        [self addSubview:self.orderImage];
        [self addSubview:self.payImage];
        [self addSubview:self.shipImage];
        [self addSubview:self.orderLabel];
        [self addSubview:self.payLabel];
        [self addSubview:self.shipLabel];
    
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset(35);
            make.height.mas_offset(4);
            make.leading.mas_equalTo(self).mas_offset(62);
            make.trailing.mas_equalTo(self).mas_offset(-62);
        }];
 
        [self.orderImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32));
            make.trailing.mas_equalTo(self.progressView.mas_leading).mas_offset(16);
            make.centerY.mas_equalTo(self.progressView.mas_centerY);
        }];
        
        [self.payImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.orderImage);
            make.center.mas_equalTo(self.progressView);
        }];
        
        [self.shipImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.orderImage);
            make.leading.mas_equalTo(self.progressView.mas_trailing).mas_offset(-16);
            make.centerY.mas_equalTo(self.progressView.mas_centerY);
        }];
        
        [self.orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.orderImage.mas_bottom).mas_offset(5);
            make.centerX.mas_equalTo(self.orderImage);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.25);
//            make.height.mas_offset(16);
        }];
        
        [self.payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.orderLabel.mas_top);
            make.centerX.mas_equalTo(self.payImage);
            make.width.mas_equalTo(self.orderLabel);
//            make.height.mas_equalTo(self.orderLabel);
        }];
        
        [self.shipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.orderLabel.mas_top);
            make.centerX.mas_equalTo(self.shipImage);
            make.width.mas_equalTo(self.orderLabel);
//            make.height.mas_equalTo(self.orderLabel);
            make.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Property Method

- (UIImageView *)orderImage
{
    if (!_orderImage) {
        _orderImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"order_icon"];
            img;
        });
    }
    return _orderImage;
}

- (UIImageView *)payImage
{
    if (!_payImage) {
        _payImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"order_pay_icon"];
            img;
        });
    }
    return _payImage;
}

- (UIImageView *)shipImage
{
    if (!_shipImage) {
        _shipImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"order_ship_icon"];
            img;
        });
    }
    return _shipImage;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = ZFC0xFE5269();
        _progressView.trackTintColor = ColorHex_Alpha(0xEDEDED, 1.0);
        _progressView.progress = 0.2;
    }
    return _progressView;
}

-(UILabel *)orderLabel
{
    if (!_orderLabel) {
        _orderLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"PaySuccess_GenerateOrder", nil);
            label.textColor = ZFC0xFE5269();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _orderLabel;
}

-(UILabel *)payLabel
{
    if (!_payLabel) {
        _payLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"PayOrder_WaitingPayment", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _payLabel;
}

-(UILabel *)shipLabel
{
    if (!_shipLabel) {
        _shipLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"PayOrder_ShipGoods", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _shipLabel;
}

@end

#pragma mark - ZFOfflineOrderInfoCCell

@interface ZFOfflineOrderInfoCCell ()

@property (nonatomic, strong) ZFCCellHeadInfo *headView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *orderNumLabel;

@end

@implementation ZFOfflineOrderInfoCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headView];
        [self addSubview:self.tipsLabel];
        [self addSubview:self.orderNumLabel];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(KScreenWidth);
        }];
        
        [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self);
            make.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self);
        }];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(16);
            make.trailing.mas_equalTo(self).mas_offset(-16);
            make.top.mas_equalTo(self.headView.mas_bottom).mas_offset(24);
        }];
        
        [self.orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.mas_equalTo(self.tipsLabel);
            make.top.mas_equalTo(self.tipsLabel.mas_bottom).mas_offset(12);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-5);
        }];
    }
    return self;
}

#pragma mark - Property Method

-(void)setModel:(ZFOrderPayResultModel *)model
{
    _model = model;
    
    NSString *orderNum = [NSString stringWithFormat:@"%@ :", ZFLocalizedString(@"OrderDetail_Order_Cell_Order", nil)];
    NSDictionary *attriParams = @{NSForegroundColorAttributeName : ZFC0x999999()};
    NSString *orderContent = [NSString stringWithFormat:@"%@ %@",orderNum, model.parentOrderSn];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:orderContent];
    [attriString addAttributes:attriParams range:NSMakeRange(0, orderNum.length)];
    self.orderNumLabel.attributedText = attriString.copy;
}

- (ZFCCellHeadInfo *)headView
{
    if (!_headView) {
        _headView = [[ZFCCellHeadInfo alloc] init];
    }
    return _headView;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"PayOffline_PayTips", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _tipsLabel;
}

-(UILabel *)orderNumLabel
{
    if (!_orderNumLabel) {
        _orderNumLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _orderNumLabel;
}

@end
