//
//  OSSVCartShippingMethodCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVCartShippingModel;

@interface OSSVCartShippingMethodCell : UITableViewCell

+ (OSSVCartShippingMethodCell *)cartCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVCartShippingModel     *shippingModel;
@property (nonatomic, strong) UILabel               *shippingMethodTitle;
@property (nonatomic, strong) UILabel               *shippingMethodPrice;
@property (nonatomic, strong) UIView                *lineView;

- (void)setShippingModel:(OSSVCartShippingModel *)shippingModel curRate:(RateModel *)curate;

@end
