//
//  STLHomeBannerTabGoodsApi.m
// XStarlinkProject
//
//  Created by odd on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVHomesMenuTabGoodAip.h"
@import RangersAppLog;

@interface OSSVHomesMenuTabGoodAip ()

@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, assign) NSInteger page;

@end

@implementation OSSVHomesMenuTabGoodAip

-(instancetype)initWithCatId:(NSString *)catId channelId:(NSString*)channel_id page:(NSInteger)page{
    self = [super init];
    
    if (self) {
        self.cat_id = catId;
        self.page = page;
        self.channel_id = channel_id;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_BannerTabGoodsList];
}

- (id)requestParameters {
    
    NSString *newRecommand_ab = [BDAutoTrack ABTestConfigValueForKey:@"Recommand_Ab" defaultValue:@""];

    NSMutableDictionary *params = [@{
        @"cat_id"            : STLToString(self.cat_id),
        @"channel_id"            : STLToString(self.channel_id),
        @"page"            : @(self.page),
        @"page_size"            : @(20)
    } mutableCopy];

    if (OSSVAccountsManager.sharedManager.sysIniModel.recommend_abtest_switch){
        [params setObject:STLToString(newRecommand_ab) forKey:@"rec_engine"];
    }
#if DEBUG
    ///test recommend
//    [params setObject:@"BT" forKey:@"rec_engine"];
#endif
    return params;

}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
