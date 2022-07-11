//
//  OSSVMysCouponItemsCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVMyCouponsListsModel;
@interface OSSVMysCouponItemsCell : UITableViewCell

@property (nonatomic, strong) OSSVMyCouponsListsModel *model;
+(OSSVMysCouponItemsCell*)myCouponsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)contentHeigth:(OSSVMyCouponsListsModel *)model;

@end
