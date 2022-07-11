//
//  STLMasterModule.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLMasterModule.h"

@implementation STLMasterModule

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static STLMasterModule *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[STLMasterModule alloc] init];
    });
    return manager;
}


///测试域名分支
-(NSString *)testDomainBranch {
    //因为国际站原因，不能调用本地的
    NSString *url = [STLWebsitesGroupManager currentCountrySiteDomain];
    return url;
}

///正式域名分支
-(NSString *)releaseDomainBranch {
    //因为国际站原因，不能调用本地的
    NSString *url = [STLWebsitesGroupManager currentCountrySiteDomain];
    return url;

}

///预发布域名分支
-(NSString *)preReleaseDomainBranch {
    //因为国际站原因，不能调用本地的
    NSString *url = [STLWebsitesGroupManager currentCountrySiteDomain];
    return url;
}


- (NSString *)testBranch {
    return @"release";
}

-(NSString *)domainVersion {
    return @"v1_20";
}

-(BOOL)isENC {
    if ([OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveTrunk ||
        [OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
}

-(BOOL)isGlobalegrowpProfile {
    return YES;
}

@end
