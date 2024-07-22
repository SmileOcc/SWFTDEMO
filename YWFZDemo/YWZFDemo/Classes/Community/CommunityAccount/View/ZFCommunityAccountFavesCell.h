//
//  ZFCommunityFavesListCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityFavesItemModel.h"

typedef void(^CommunityFavesLikeCompletionHandler)(ZFCommunityFavesItemModel *model);

@interface ZFCommunityAccountFavesCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityFavesItemModel                 *favesModel;
@property (nonatomic, copy) CommunityFavesLikeCompletionHandler         communityFavesLikeCompletionHandler;

@end
