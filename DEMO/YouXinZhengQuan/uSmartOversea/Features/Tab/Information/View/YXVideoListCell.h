//
//  YXVideoListCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXLiveModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXVideoListCell : UICollectionViewCell

@property (nonatomic, strong) NSArray <YXLiveModel *> *replayList;

@property (nonatomic, copy) void (^clickItemCallBack)(YXLiveModel *model);

@end

NS_ASSUME_NONNULL_END
