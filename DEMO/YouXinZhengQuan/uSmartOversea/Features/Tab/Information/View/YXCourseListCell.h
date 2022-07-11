//
//  YXCourseListCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXNewCourseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXCourseListCell : UICollectionViewCell

@property (nonatomic, strong) NSArray <YXNewCourseVideoInfoModel *>*list;

@property (nonatomic, copy) void (^clickSetItemCallBack)(YXNewCourseSetVideoInfoSubModel *setModel, NSString *videoId);

@property (nonatomic, copy) void (^clickVideoItemCallBack)(YXNewCourseVideoInfoSubModel *videoModel);

@end

NS_ASSUME_NONNULL_END
