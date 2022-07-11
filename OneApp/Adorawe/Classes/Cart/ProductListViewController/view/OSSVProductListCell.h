//
//  OSSVProductListCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>
#import "OSSVCartGoodsModel.h"

@interface OSSVProductListCell : UITableViewCell

@property (nonatomic, strong) OSSVCartGoodsModel   *cartGoodsModel;
@property (nonatomic, strong) RateModel        *rateModel;
@property (nonatomic, strong) UIView           *lineView;

@property (nonatomic, assign) BOOL             showLeftCount;

@end
