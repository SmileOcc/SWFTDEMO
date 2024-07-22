//
//  ZFCommunityPostDetailPageVC.h
//  ZZZZZ
//
//  Created by YW on 2019/1/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "WMPageController.h"
#import "ZFAppsflyerAnalytics.h"


/**
 社区帖子详情(新)
 */
@interface ZFCommunityPostDetailPageVC : WMPageController

@property (nonatomic, copy) NSString                     *reviewID;
@property (nonatomic, assign) ZFAppsflyerInSourceType    sourceType;
@property (nonatomic, assign) BOOL                       isOutfits;

/// 商详Shows带入关联帖子id数组
@property (nonatomic, strong) NSArray                    *reviewIDArray;

- (instancetype)initWithReviewID:(NSString *)reviewID title:(NSString *)titleString;

@end

