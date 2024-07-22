//
//  ZFCommunityLiveVideoActivityModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoRedNetModel : NSObject
/** 红人封面*/
@property (nonatomic, copy) NSString *pic_url;
/** 跳转链接*/
@property (nonatomic, copy) NSString *link_url;

/** 跳转链接*/
@property (nonatomic, copy) NSString *pic_width;
/** 跳转链接*/
@property (nonatomic, copy) NSString *pic_height;

@end

NS_ASSUME_NONNULL_END
