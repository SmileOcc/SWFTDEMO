//
//  ZFCommunityOutfitPostVC.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFOutfitItemModel.h"
#import "ZFCommunityHotTopicModel.h"

/**
 穿搭发帖
 */
@interface ZFCommunityOutfitPostVC : ZFBaseViewController

/// 选择的热门话题
@property (nonatomic, strong) ZFCommunityHotTopicModel    *selectHotTopicModel;
@end
