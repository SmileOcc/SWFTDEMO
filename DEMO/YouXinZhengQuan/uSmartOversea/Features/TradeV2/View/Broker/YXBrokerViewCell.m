//
//  YXBrokerViewCell.m
//  YouXinZhengQuan
//
//  Created by 井超 on 2020/3/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerViewCell.h"

#import <Masonry/Masonry.h>

@interface YXBrokerViewCell ()



@end

@implementation YXBrokerViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)initialUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.brokerView];
    [self.brokerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
//        make.height.mas_equalTo(0);
         make.height.mas_equalTo(22 * 5 + 32);
    }];
}

- (YXStockDetailBrokerView *)brokerView {
    if (_brokerView == nil) {
        _brokerView = [[YXStockDetailBrokerView alloc] init];
    }
    return _brokerView;
}

@end
