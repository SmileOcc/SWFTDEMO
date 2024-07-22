

//
//  ZFOrderDetailDeliveryShippingCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailDeliveryShippingCell.h"
#import "ZFInitViewProtocol.h"
#import "OrderDetailOrderModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFOrderDetailDeliveryShippingCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *deliveryLabel;
@end

@implementation ZFOrderDetailDeliveryShippingCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.deliveryLabel];
}

- (void)zfAutoLayoutView {
    [self.deliveryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(15, 12, 24, 12));
    }];
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    
    if ([_model.show_refund integerValue] == 2) {
        self.deliveryLabel.text = ZFLocalizedString(@"OrderRefundTips", nil);
    } else {
        self.deliveryLabel.text = ZFLocalizedString(@"DeliveryShippingView_deliveryLabel", nil);
    }
}

#pragma mark - getter
- (UILabel *)deliveryLabel {
    if (!_deliveryLabel) {
        _deliveryLabel = [[UILabel alloc] init];
        _deliveryLabel.backgroundColor = [UIColor clearColor];
        _deliveryLabel.text = ZFLocalizedString(@"DeliveryShippingView_deliveryLabel", nil);
        _deliveryLabel.textColor = ZFCOLOR(52, 52, 52, 1.0);
        _deliveryLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
        _deliveryLabel.numberOfLines = 0;
        [_deliveryLabel sizeToFit];
        _deliveryLabel.font = [UIFont systemFontOfSize:14];
    }
    return _deliveryLabel;
}
@end
