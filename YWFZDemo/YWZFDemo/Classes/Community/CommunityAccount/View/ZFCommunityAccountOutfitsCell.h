//
//  ZFCommunityAccountOutfitsCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFCommunityOutfitsModel;

typedef void(^CommunityAccountOutfitsLikeCompletionHandler)(ZFCommunityOutfitsModel *model);

@interface ZFCommunityAccountOutfitsCell : UICollectionViewCell
@property (nonatomic, strong) ZFCommunityOutfitsModel       *model;

@property (nonatomic, copy) CommunityAccountOutfitsLikeCompletionHandler    communityAccountOutfitsLikeCompletionHandler;
@end
