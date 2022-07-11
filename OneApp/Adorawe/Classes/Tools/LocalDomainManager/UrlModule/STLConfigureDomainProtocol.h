//
//  STLConfigureDomainProtocol.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STLConfigureDomainProtocol <NSObject>

///测试域名分支
-(NSString *)testDomainBranch;

///替换分支
- (NSString *)testBranch;

///正式域名分支
-(NSString *)releaseDomainBranch;

-(NSString *)preReleaseDomainBranch;

///域名版本
-(NSString *)domainVersion;

///接口是否需要加密
//-(BOOL)isENC;

///接口是否需要配合后台做性能测试 <已废弃>
-(BOOL)isGlobalegrowpProfile;

@end
