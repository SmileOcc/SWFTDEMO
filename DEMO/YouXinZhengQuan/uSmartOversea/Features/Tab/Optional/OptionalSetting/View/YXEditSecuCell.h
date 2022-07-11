//
//  YXEditStockCell.h
//  uSmartOversea
//
//  Created by ellison on 2018/10/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YXV2Quote;
@class YXMarketIconLabel;

@interface YXEditSecuCell : UITableViewCell

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) dispatch_block_t onClickStick;
@property (nonatomic, copy) dispatch_block_t onClickCheck;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) YXMarketIconLabel *marketLabel;

- (void)checkButtonAction;

@end

NS_ASSUME_NONNULL_END
