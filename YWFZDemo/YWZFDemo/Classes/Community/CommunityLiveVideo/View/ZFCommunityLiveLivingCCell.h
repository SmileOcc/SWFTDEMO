//
//  ZFCommunityLiveVideoLiveCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>

#import "ZFCommunityLiveListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveLivingCCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityLiveListModel *liveItemModel;

@property (nonatomic, strong) YYAnimatedImageView               *coverImageView;

@end

NS_ASSUME_NONNULL_END
