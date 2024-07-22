//
//  ZFGeshopNavigationItemCell.h
//  ZZZZZ
//
//  Created by YW on 2019/9/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGeshopSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFGeshopNavigationItemCell : UICollectionViewCell

@property (nonatomic, strong) ZFGeshopSectionListModel *listModel;

@property (nonatomic, strong) ZFGeshopComponentStyleModel *styleModel;

@end

NS_ASSUME_NONNULL_END
