//
//  DiscoveryItemCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const CGFloat kDiscoveryCellImageHeight; // DiscoveryItemCell 高度
UIKIT_EXTERN const CGFloat kDiscoveryCellSpace; // cell 之间的间距

@class OSSVAdvsEventsModel;

//////测试数据 已废弃
@interface OSSVDiscoveyItemCell : UITableViewCell

+ (OSSVDiscoveyItemCell *)discoveryItemCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) OSSVAdvsEventsModel *bannerModel;

@end
