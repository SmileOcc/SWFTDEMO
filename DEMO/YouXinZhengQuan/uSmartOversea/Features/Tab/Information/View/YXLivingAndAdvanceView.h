//
//  YXLivingAndAdvanceView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXLivingAndAdvanceView : UICollectionViewCell

@property (nonatomic, strong) NSArray *liveList;

@property (nonatomic, copy) void (^clickItemCallBack)(YXLiveModel *liveModel);

@end

NS_ASSUME_NONNULL_END
