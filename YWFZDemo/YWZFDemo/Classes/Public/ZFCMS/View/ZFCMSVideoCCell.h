//
//  ZFCMSVideoCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/9/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  CMS播放视频组件

#import <UIKit/UIKit.h>
#import "ZFCMSSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickPlayerVideo)(ZFCMSItemModel *itemModel);

@interface ZFCMSVideoCCell : UICollectionViewCell

+ (ZFCMSVideoCCell *)reusableTextModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) ZFCMSItemModel *itemModel;

@property (nonatomic, copy) clickPlayerVideo CMSCellPlayerVideo;

@end

NS_ASSUME_NONNULL_END
