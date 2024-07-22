//
//  ZFCommunityVideoDetailInfoModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/30.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 **************************************
 *
 *
 *  视频详情 -> 视频头部信息数据model
 *
 *
 ***************************************
 */

#import <Foundation/Foundation.h>

@interface ZFCommunityVideoDetailInfoModel : NSObject

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, assign) NSInteger viewNum;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, copy) NSString *videoDescription;

@property (nonatomic, copy) NSString *likeNum;

@property (nonatomic, assign) NSInteger isLike;

@end


