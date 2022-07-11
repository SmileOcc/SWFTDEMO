//
//  YXBaseStockListCell.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXTableViewCell.h"
#import "YXSecuProtocol.h"
#import "YXSecuMobileBrief1Protocol.h"
#import "YXSecuNameLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBaseStockListCell : YXTableViewCell

@property (nonatomic, strong) YXModel<YXSecuProtocol> *model;

//@property (nonatomic, strong) UIImageView *marketIconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) QMUILabel *delayLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *rocLabel;
@property (nonatomic, strong) UIView *lineView;

@end

NS_ASSUME_NONNULL_END
