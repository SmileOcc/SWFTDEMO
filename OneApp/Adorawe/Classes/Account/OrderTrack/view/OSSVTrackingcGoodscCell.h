//
//  OSSVTrackingcGoodscCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVTrackingcGoodListcModel;

@interface OSSVTrackingcGoodscCell : UITableViewCell

+ (OSSVTrackingcGoodscCell*)trackingGoodsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVTrackingcGoodListcModel *goodListModel;


@end
