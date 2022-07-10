//
//  WYFileService.h
//  PropertyManagement
//
//  Created by  jiangminjie on 2019/4/23.
//  Copyright © 2019年 qanzone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYFileService : NSObject

+ (instancetype)sharedInstance;

#pragma mark - 上传图片到阿里云
- (void)onUpdateAliYunImageWithPostData:(NSArray *)imgDatas withSuccess:(void (^)(NSDictionary *responceDic))successBlock withFailure:(void (^)(NSString *error))failureBlock;

@end

NS_ASSUME_NONNULL_END
