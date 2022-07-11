//
//  OSSVCategoryssViewsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//


#import "OSSVCategorysAip.h"
#import "OSSVCategorysModel.h"
#import "OSSVCategoryssViewsModel.h"
#import "OSSVSecondsCategorysModel.h"
#import "OSSVCategoryMenusAip.h"
#import "OSSVCategorysMenusModel.h"

@import FirebasePerformance;

@implementation OSSVCategoryssViewsModel

#pragma mark - request

- (void)requestCategoryMenu:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure
{
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVCategoryMenusAip *api = [[OSSVCategoryMenusAip alloc] init];
        // 取缓存数据
//        if (api.cacheJSONObject) {
//            id requestJSON = api.cacheJSONObject;
//            NSArray *rusulst = [self dataAnalysisFromJson: requestJSON request:api];
//            if (completion)
//            {
//                completion(rusulst);
//            }
//        }else {
//
//        }
        
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *rusulst = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(rusulst);
            }
        }failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure)
            {
                failure(nil);
            }
        }];
    
    }exception:^{
        if (failure) {
            failure(nil);
        }
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
        
    }];
}


- (void)requestCategory:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure
{
    
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVCategorysAip *api = [[OSSVCategorysAip alloc] initCategory];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        __block FIRTrace *trace = [FIRPerformance startTraceWithName:@"category-tab-list"];
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:api];
            [trace stop];
            if (completion)
            {
                completion(self.dataArray);
            }
        }
        failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            [trace stop];
           if (failure)
           {
               failure(nil);
           }
       }];
    }
    exception:^{
      if (failure)
      {
          failure(nil);
      }
          [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];

    }];
}

#pragma mark - private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVCategorysAip class]]){
        if ([json[kStatusCode] integerValue] == kStatusCode_200){
            return [NSArray yy_modelArrayWithClass:[OSSVCategorysModel class] json:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    } else if([request isKindOfClass:[OSSVCategoryMenusAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200){
            return [NSArray yy_modelArrayWithClass:[OSSVCategorysMenusModel class] json:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}


+ (CGFloat)listFirstRangeTableWidth {
    return 105;
}
+ (CGFloat)secondRangeCollectionWidth {
    return SCREEN_WIDTH - [OSSVCategoryssViewsModel listFirstRangeTableWidth] - 12 * 2;
}

+ (CGSize)secondRangeItemSize {
    CGFloat itemWidth = ([OSSVCategoryssViewsModel secondRangeCollectionWidth] -28-16) / 3.0;
    if (APP_TYPE == 3) {
        itemWidth = ([OSSVCategoryssViewsModel secondRangeCollectionWidth] - 8) / 2.0;
    }
    CGFloat itemHeigth = floor(itemWidth) + 46;

    return CGSizeMake(itemWidth, itemHeigth);
}

+ (CGSize)cellRangeItemSize {
    CGFloat imageWidt = (SCREEN_WIDTH - 105 - 12 * 2 - 14*2 -8*2) / 3.0;
    if (APP_TYPE == 3) {
        imageWidt = (SCREEN_WIDTH - 105 - 12 * 2- 8) / 2.0;
    }

    // 50 图片下面内容高度
    CGFloat itemHeigth = floor(imageWidt) + 38;
    return CGSizeMake(imageWidt, itemHeigth);

}

@end


