//
//  OSSVAccountHeadBaseCell.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSSVAccountHeadCellTypeModel;

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountHeadBaseCell : UITableViewCell

/** Section所对应的Cell数据源 */
@property (nonatomic, strong) OSSVAccountHeadCellTypeModel *cellTypeModel;

/** Section所对应的NSindexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
