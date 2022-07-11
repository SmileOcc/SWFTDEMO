//
//  OSSVTrackingcRouteccCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVTrackingcMessagecModel;

@interface OSSVTrackingcRouteccCell : UITableViewCell

+ (OSSVTrackingcRouteccCell *)trackingRouteCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVTrackingcMessagecModel *trackingRouteMessageModel;

- (void)isNearestRouteCell;
- (void)isFarthestRouteCell;

@end
