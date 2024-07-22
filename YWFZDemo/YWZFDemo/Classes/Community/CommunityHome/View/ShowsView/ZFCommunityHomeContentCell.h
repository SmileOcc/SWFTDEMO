//
//  ZFCommunityHomeContentCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityExploreModel.h"
@class ZFBannerModel;
@class ZFCommunityFavesItemModel;

//一直没用到
@interface ZFCommunityHomeContentCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray      *datasArray;

@property (nonatomic, assign) NSInteger           selectIndex;

@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

- (void)updateDatas:(NSArray *)datas;

@end
