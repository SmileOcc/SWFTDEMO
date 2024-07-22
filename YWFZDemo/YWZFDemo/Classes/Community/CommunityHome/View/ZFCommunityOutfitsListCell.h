//
//  ZFCommunityOutfitsListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/7/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCommunityOutfitsModel;

typedef void(^CommunityOutfitsLikeCompletionHandler)(ZFCommunityOutfitsModel *model);

@interface ZFCommunityOutfitsListCell : UICollectionViewCell
@property (nonatomic, strong) ZFCommunityOutfitsModel       *model;
@property (nonatomic, copy) CommunityOutfitsLikeCompletionHandler       communityOutfitsLikeCompletionHandler;
@end
