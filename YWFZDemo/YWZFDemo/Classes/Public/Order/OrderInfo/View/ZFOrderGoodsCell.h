//
//  ZFOrderGoodsCell.h
//  ZZZZZ
//
//  Created by YW on 20/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CheckOutGoodListModel;

@interface ZFOrderGoodsCell : UITableViewCell

@property (nonatomic, strong) NSArray<CheckOutGoodListModel *>  *goodsList;

+ (NSString *)queryReuseIdentifier;

@end
