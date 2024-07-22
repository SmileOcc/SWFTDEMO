//
//  ZFCommunityVideoListHeaderView.h
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFCommunityVideoDetailInfoModel;

@interface ZFCommunityVideoListHeaderView : UIView
@property (nonatomic, copy) void (^likeBlock)(void);//点赞
@property (nonatomic, strong) ZFCommunityVideoDetailInfoModel *infoModel;
@property (nonatomic, copy) void (^refreshHeadViewBlock)(CGFloat headerHeight);//My Style Block
@end
