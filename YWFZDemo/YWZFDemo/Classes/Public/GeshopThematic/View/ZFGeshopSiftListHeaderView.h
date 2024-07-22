//
//  ZFGeshopSiftListHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGeshopSiftItemModel;

@interface ZFGeshopSiftListHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) ZFGeshopSiftItemModel *siftItemModel;

@property (nonatomic, copy) void(^touchArrowImgBlock)(ZFGeshopSiftItemModel *model);

@property (nonatomic, copy) void(^selecteCurrentSiftBlock)(ZFGeshopSiftItemModel *model);

@end
