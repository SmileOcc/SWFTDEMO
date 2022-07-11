//
//  STLCommentModule.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCommentModule.h"

@implementation STLCommentModule

-(NSString *)testDomainBranch {
    return [OSSVLocaslHosstManager appLocalTestReviewHost];
}

///正式域名分支
-(NSString *)releaseDomainBranch {
    return [OSSVLocaslHosstManager appLocalOnleReviewHost];
}

///预发布域名分支
-(NSString *)preReleaseDomainBranch {
    return [OSSVLocaslHosstManager appLocalPreOnleReviewHost];
}

+ (NSString *)reviewPictureDomainHost {
    //默认测试
    NSString *hostDomain = [OSSVLocaslHosstManager appLocalTestReviewPictureDomain];
    
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {//线上
        return [OSSVLocaslHosstManager appLocalOnleReviewPictureDomain];
        
    } else if([OSSVConfigDomainsManager isPreRelease]) {//预发布
        return [OSSVLocaslHosstManager appLocalPreOnleReviewPictureDomain];
    }
    
    return hostDomain;
}

- (NSString *)testBranch {
    return @"release";
}
-(NSString *)domainVersion
{
    return @"";
}

-(BOOL)isENC
{
    return NO;
}

-(BOOL)isGlobalegrowpProfile
{
    return NO;
}

@end
