//
//  ZFCommunityPostTagViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/6/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 发帖标签
 */
@interface ZFCommunityPostTagViewModel : NSObject

// 请求发帖标签
- (void)requestPostTagRequestWithFinished:(void(^)(void))finishedHandle;

// 发帖
- (void)postRequestWithParams:(NSDictionary *)params finished:(void (^)(NSString *result))finishedHandle;

// 获取标签
- (NSArray <NSString *> *)tagArray;


@end
