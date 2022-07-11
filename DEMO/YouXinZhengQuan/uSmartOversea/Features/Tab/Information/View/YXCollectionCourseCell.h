//
//  YXCollectionViewCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXNewCourseSetVideoInfoSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXCollectionCourseCell : UICollectionViewCell

@property (nonatomic, strong) YXNewCourseSetVideoInfoSubModel *courseModel;

@property (nonatomic, copy) void (^clickCallBack)(NSString *videoId);

@end

NS_ASSUME_NONNULL_END
