//
//  OSSVCartShippingMethodCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartShippingMethodCell.h"

#import "OSSVCartShippingModel.h"

@implementation OSSVCartShippingMethodCell

+ (OSSVCartShippingMethodCell *)cartCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[OSSVCartShippingMethodCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCartShippingMethodCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVCartShippingMethodCell.class) forIndexPath:indexPath];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;

        UIView *ws = self.contentView;
        [ws addSubview:self.shippingMethodTitle];
        [ws addSubview:self.shippingMethodPrice];
        [ws addSubview:self.lineView];

        [self.shippingMethodTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top).offset(16);
            make.leading.mas_equalTo(ws.mas_leading).offset(10);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-10);
        }];
        
        [self.shippingMethodPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shippingMethodTitle.mas_bottom).offset(10);
            make.leading.mas_equalTo(self.shippingMethodTitle.mas_leading);
            make.bottom.mas_equalTo(ws.mas_bottom).offset(-16);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.bottom.mas_equalTo(ws.mas_bottom);
            make.height.mas_equalTo(@1);
        }];
    }
    return self;
}

#pragma mark -
- (void)prepareForReuse {
    [super prepareForReuse];
    self.shippingMethodTitle.text = nil;
    self.shippingMethodPrice.text = nil;
}

- (void)setShippingModel:(OSSVCartShippingModel *)shippingModel curRate:(RateModel *)curate {
    _shippingModel = shippingModel;
    self.shippingMethodTitle.text = [NSString stringWithFormat:@"%@(%@)",shippingModel.shipName,shippingModel.shipDesc];
    
//    self.shippingMethodPrice.text = curate ? [ExchangeManager changeRateModel:curate transforPrice:shippingModel.shippingFee] : [ExchangeManager transforPrice:shippingModel.shippingFee];
    
    self.shippingMethodPrice.text = STLToString(shippingModel.shipping_fee_converted);
}

#pragma mark - LazyLoad

- (UILabel *)shippingMethodTitle {
    if (!_shippingMethodTitle) {
        _shippingMethodTitle = [UILabel new];
        _shippingMethodTitle.font = [UIFont systemFontOfSize:14];
        _shippingMethodTitle.numberOfLines = 2;
        _shippingMethodTitle.textColor = OSSVThemesColors.col_666666;
    }
    return _shippingMethodTitle;
}

- (UILabel *)shippingMethodPrice {
    if (!_shippingMethodPrice) {
        _shippingMethodPrice = [UILabel new];
        _shippingMethodPrice.font = [UIFont systemFontOfSize:14];
        _shippingMethodPrice.textColor = OSSVThemesColors.col_333333;
    }
    return _shippingMethodPrice;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
    }
    return _lineView;
}
@end
