//
//  ZFCommunityHomeVC.h
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"

//社区页面三个列表
typedef NS_ENUM(NSInteger, ZFCommunityHomeSelectType) {
    ZFCommunityHomeSelectTypeExplore = 0,
    ZFCommunityHomeSelectTypeOutfits,
    ZFCommunityHomeSelectTypeVideo
};

@interface ZFCommunityHomeVC : ZFBaseViewController

/**
 * 外部跳转到制定页面
 */
- (void)bannerJumpToSelectType:(ZFCommunityHomeSelectType)type;

@end

