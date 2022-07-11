//
//  OSSVConfigDomainsManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  本地域名管理器

#import <Foundation/Foundation.h>
#import "STLMasterModule.h"
#import "STLCommentModule.h"


static NSString* const STLOpenLogSystemTag     = @"1001";


static NSString* const masterDomain         = @"masterDomain";
static NSString* const commentDomain        = @"commentDomain";
static NSString* const STLBranch            = @"STLBranch";
static NSString* const STLBranchNum         = @"STLBranchNum";
static NSString* const STLVersion           = @"STLVersion";
///国家站点
static NSString* const STLSiteCode           = @"STLSiteCode";

static NSString* const STLCatchLogTagKey    = @"STLCatchLogTagKey";
static NSString* const STLCatchLogURLKey    = @"STLCatchLogUrlKey";

///开发模式
static NSString* const STLDevelopmentModel  = @"STLPattern";

///开发环境
typedef NS_ENUM(NSInteger) {
    DomainType_DeveTrunk     = 1 << 0,               //<开发模式
    DomainType_Pre_Release   = 1 << 1,              ///<预发布模式
    DomainType_Release       = 1 << 2,              ///<发布模式 <发布模式下，所有的域名都是正式环境>
    DomainType_DeveInput     = 1 << 3,
}DomainType;

@interface OSSVConfigDomainsManager : NSObject

//<初始化本地域名
+(instancetype)sharedInstance;

//<开发环境
+(DomainType)domainEnvironment;

+(BOOL)isDistributionOnlineRelease;

+(BOOL)isPreRelease;

//+ (BOOL)isDevelopStatus;

//测试自定义分支
-(NSString *)gainCustomerBranch;

//测试自定义版本号
-(NSString *)gainCustomerVersion;

//测试自定义分支号
-(NSString *)gainCustomerBranchNum;

///设置自定义开发模式
-(void)setCustomerDevelopmentModel:(DomainType)type;

+(id<STLConfigureDomainProtocol>)gainDomainModule:(NSString *)domain;

-(NSInteger)thirdConfigureEnvironment;


#pragma mark - 这是一些特殊的接口域名

///<AppH5Url
@property (nonatomic, copy, readonly) NSString *appH5Url;





+ (NSString *)localBranch;
+ (void)saveLocalBranch:(NSString *)branch;

+ (NSString *)localBranchNum;
+ (NSString *)localBranchVersion;
+ (void)saveLocalBranchVersion:(NSString *)branchVersion;

+ (NSString *)localRequestLogToUrl;

+ (NSString *)localCatchLogTagKey;
+ (void)saveLocalCatchLogTagKey:(NSString *)tagKey;

+ (NSString *)localCatchLogURLKey;
+ (void)saveLocalCatchLogURLKey:(NSString *)urlKey;

@end
