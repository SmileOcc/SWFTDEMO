//
//  ZFAccountHeaderBaseCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFAccountHeaderCellTypeModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFAccountHeaderBaseCell : UITableViewCell

/** Section所对应的Cell数据源 */
@property (nonatomic, strong) ZFAccountHeaderCellTypeModel *cellTypeModel;

/** Section所对应的NSindexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
