//
//  OSSVCartCouponItemCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVMyCouponsListsModel;
@interface OSSVCartCouponItemCell : UITableViewCell

+(OSSVCartCouponItemCell*)CartCouponsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)setModel:(OSSVMyCouponsListsModel *)model index:(NSInteger)index;
@property (nonatomic, strong) OSSVMyCouponsListsModel *model;
+ (CGFloat)contentHeigth;
@end
