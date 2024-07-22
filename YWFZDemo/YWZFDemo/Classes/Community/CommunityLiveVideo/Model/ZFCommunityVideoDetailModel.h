//
//  ZFCommunityVideoDetailModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 **************************************
 *
 *
 *  视频详情 -> 视频数据model
 *
 *
 ***************************************
 */

#import <Foundation/Foundation.h>

@class ZFCommunityVideoDetailInfoModel;

@interface ZFCommunityVideoDetailModel : NSObject

@property (nonatomic, strong) ZFCommunityVideoDetailInfoModel *videoInfo;

@property (nonatomic, strong) NSArray *goodsList;

@end
