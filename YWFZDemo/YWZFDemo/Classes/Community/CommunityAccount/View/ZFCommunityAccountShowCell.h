//
//  ZFCommunityAccountShowCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityAccountShowsModel.h"

typedef void(^CommunityAccountShowsLikeCompletionHandler)(ZFCommunityAccountShowsModel *model);

@interface ZFCommunityAccountShowCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityAccountShowsModel      *showsModel;

@property (nonatomic, copy) CommunityAccountShowsLikeCompletionHandler          communityAccountShowsLikeCompletionHandler;
@end
