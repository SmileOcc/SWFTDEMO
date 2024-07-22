//
//  ZFCommunityPostTagViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/6/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostTagViewModel.h"
#import "TabObtainApi.h"
#import "PostApi.h"
#import "NSDictionary+SafeAccess.h"
#import "Constants.h"

@interface ZFCommunityPostTagViewModel()

@property (nonatomic, strong) NSArray <NSString *> *tags;

@end

@implementation ZFCommunityPostTagViewModel

- (void)requestPostTagRequestWithFinished:(void (^)(void))finishedHandle {
    TabObtainApi *api = [[TabObtainApi alloc] init];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.tags = [request.responseJSONObject ds_arrayForKey:@"data"];
        if (finishedHandle) {
            finishedHandle();
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (finishedHandle) {
            finishedHandle();
        }
    }];
    
}

- (void)postRequestWithParams:(NSDictionary *)params finished:(void (^)(NSString *result))finishedHandle {
    PostApi *api = [[PostApi alloc] initWithDict:params];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        NSString *msg = [request.responseJSONObject ds_stringForKey:@"msg"];
        if (finishedHandle) {
            finishedHandle(msg);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (finishedHandle) {
            finishedHandle(@"");
        }
    }];
}

- (NSArray<NSString *> *)tagArray {
    return self.tags;
}

@end
