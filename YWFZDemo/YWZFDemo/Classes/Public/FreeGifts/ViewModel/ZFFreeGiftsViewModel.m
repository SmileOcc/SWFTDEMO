
//
//  ZFFreeGiftsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFreeGiftsViewModel.h"
#import "ZFFreeGiftListModel.h"
#import "ZFRequestModel.h"

@interface ZFFreeGiftsViewModel()

@end

@implementation ZFFreeGiftsViewModel

+ (void)requestFreeGiftListNetwork:(id)parmaters
                        completion:(void (^)(NSMutableArray *dataArray))completion
                           failure:(void (^)(id obj))failure {
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:parmaters success:^(id responseObject) {
        NSMutableArray *freeGiftList = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[ZFFreeGiftListModel class] json:responseObject[@"result"]]];
        if (completion) {
            completion(freeGiftList);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
