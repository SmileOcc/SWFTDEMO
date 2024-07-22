//
//  ZFOrderBottomTipsCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  确认订单页底部cell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFOrderInfoFooterModel;

typedef void(^OrderInfoH5Block)(NSString *url);

@interface ZFOrderBottomTipsCell : UITableViewCell

@property (nonatomic, copy) OrderInfoH5Block   orderInfoH5Block;

@property (nonatomic, strong) ZFOrderInfoFooterModel   *model;

+ (NSString *)queryReuseIdentifier;

@end

NS_ASSUME_NONNULL_END
