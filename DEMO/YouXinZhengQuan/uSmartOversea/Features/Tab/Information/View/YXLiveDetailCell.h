//
//  YXLiveDetailCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXLiveModel;
@class YXNewCourseVideoInfoSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveDetailCell : UICollectionViewCell

@property (nonatomic, strong) YXLiveModel *liveModel;

@property (nonatomic, strong) YXNewCourseVideoInfoSubModel *courseModel;

@end

@interface YXLiveRecommendDetailCell : UICollectionViewCell

@property (nonatomic, strong) YXNewCourseVideoInfoSubModel *courseModel;

@end

NS_ASSUME_NONNULL_END
