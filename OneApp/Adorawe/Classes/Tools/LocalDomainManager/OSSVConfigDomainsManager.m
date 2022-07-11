//
//  OSSVConfigDomainsManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVConfigDomainsManager.h"

@interface OSSVConfigDomainsManager ()
@property (nonatomic, assign) DomainType customerDomainType;                    ///<设置 APP开发环境
@property (nonatomic, copy) NSString *customerDomainBranch;                     ///<开发设置分支
@property (nonatomic, copy) NSString *customerDomainNum;                        ///<开发分支num
@end

@implementation OSSVConfigDomainsManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static OSSVConfigDomainsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[OSSVConfigDomainsManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        ///此处设置APP的域名配置

        if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            
            self.customerDomainType = DomainType_DeveTrunk;
            if (AppRequestType == 1) {
                self.customerDomainType = DomainType_Pre_Release;
            }
            self.customerDomainBranch = @"";
            self.customerDomainNum = @"";
        } else {
            self.customerDomainType = DomainType_Release;
            self.customerDomainBranch = @"";
            self.customerDomainNum = @"";
        }
    }
    return self;
}

#pragma mark - public method

+(DomainType)domainEnvironment {

    if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        NSInteger environment = [[NSUserDefaults standardUserDefaults] integerForKey:STLDevelopmentModel];
        if (environment) {
            return environment;
        }else{
            return [OSSVConfigDomainsManager sharedInstance].customerDomainType;
        }
    }
    return [OSSVConfigDomainsManager sharedInstance].customerDomainType;
}


+(id<STLConfigureDomainProtocol>)gainDomainModule:(NSString *)domain {

    if ([domain isEqualToString:masterDomain]) {
        return [[STLMasterModule alloc] init];
    }else if ([domain isEqualToString:commentDomain]){
        return [[STLCommentModule alloc] init];
    }
    return nil;
}

+ (BOOL)isDistributionOnlineRelease {
    BOOL isDistributionOnlineRelease = NO;
    if (AppRequestType == 2) { //线上发布生产环境
        isDistributionOnlineRelease = YES;
    }
    return isDistributionOnlineRelease;
}

+ (BOOL)isPreRelease {
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        return NO;
    }
    
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if (type == DomainType_Pre_Release) {
        return YES;
    }
    return NO;
}

/**
 * 当前环境是否为开发环境
 */
//+ (BOOL)isDevelopStatus
//{
//    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {//线上发布直接返回
//        return NO;
//    }
//    NSInteger envType = [STLUserDefaultsGet(STLDevelopmentModel) integerValue];
//    return envType & DomainType_DeveTrunk || envType & DomainType_DeveInput;
//}

///获取测试自定义分支
-(NSString *)gainCustomerBranch {
    NSString *branch = @"";
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if (type == DomainType_Release) {
        branch = @"正式环境";
    }else if (type == DomainType_Pre_Release) {
        branch = @"预发布环境";
    }else if (type == DomainType_DeveInput) {
        branch = [OSSVConfigDomainsManager localBranch];
    } else {
        branch = @"主分支";
    }
    if (STLIsEmptyString(branch)) {
        branch = self.customerDomainBranch;
    }
    return branch;
}

///获取测试自定义版本号
-(NSString *)gainCustomerVersion {
    NSString *version = [OSSVConfigDomainsManager localBranchVersion];
    if (STLIsEmptyString(version)) {
        return [[OSSVConfigDomainsManager gainDomainModule:masterDomain] domainVersion];
    }
    return version;
}

///获取测试自定义分支号
-(NSString *)gainCustomerBranchNum {
    NSString *branchNum = [OSSVConfigDomainsManager localBranchNum];
    if (STLIsEmptyString(branchNum)) {
        if (self.customerDomainNum.integerValue > 0) {
            branchNum = self.customerDomainNum;
        }else{
            branchNum = @"";
        }
    }
    return branchNum;
}

///设置自定义开发模式
-(void)setCustomerDevelopmentModel:(DomainType)type
{
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:STLDevelopmentModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 保存到数据共享组
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
    [myDefaults setInteger:type forKey:@"EnvSettingTypeKey"];
}

-(NSInteger)thirdConfigureEnvironment {
    
    //除了发布线上配置，其他都是Debug
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        return 1;
    }
    return 0;
//    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
//    if (type == DomainType_Release) {
//        return 1;
//    }else{
//        return 0;
//    }
}

#pragma mark - setter and getter

-(NSString *)appH5Url
{
    id <STLConfigureDomainProtocol> domainModule = [OSSVConfigDomainsManager gainDomainModule:masterDomain];
    NSString *domainUrl = @"";
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];
    if (domainType == DomainType_Release) {
        domainUrl = [domainModule releaseDomainBranch];
    }else if(domainType == DomainType_Pre_Release) {
        domainUrl = [domainModule preReleaseDomainBranch];
    } else{
        domainUrl = [domainModule testDomainBranch];
//        NSString *branchStr = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
//        if (!branchStr || [branchStr isEqualToString:@"主分支"]) {
//            branchStr = [domainModule testBranch];
//        }
//        NSString *branchNum = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranchNum];
//        if (branchNum.integerValue > 0) {
//            branchStr = [NSString stringWithFormat:@"%@%@", branchStr, branchNum];
//        }
//        domainUrl = [domainUrl stringByReplacingOccurrencesOfString:[domainModule testBranch] withString:branchStr];
    }
    return domainUrl;
}




+ (NSString *)localRequestLogToUrl {
    NSString *catchLogUrl = [OSSVConfigDomainsManager localCatchLogURLKey];
    if (STLIsEmptyString(catchLogUrl)) {
//        return [NSString stringWithFormat:@"http://10.250.0.153:8090/pullLogcat"];
        return [NSString stringWithFormat:@"http://10.1.3.233:8090/pullLogcat"];
    }
    if (![catchLogUrl containsString:@":"]) {
        catchLogUrl = [catchLogUrl stringByAppendingString:@":8090"];
    }
    return [NSString stringWithFormat:@"http://%@/pullLogcat",catchLogUrl];
}

///////
+ (NSString *)localBranch {
    NSString *log = [[NSUserDefaults standardUserDefaults] objectForKey:STLBranch];
    return  STLToString(log);
}

+ (void)saveLocalBranch:(NSString *)branch {
    [[NSUserDefaults standardUserDefaults] setObject:STLToString(branch) forKey:STLBranch];
}

+ (NSString *)localBranchNum {
    NSString *log = [[NSUserDefaults standardUserDefaults] objectForKey:STLBranchNum];
    return  STLToString(log);
}


////////
+ (NSString *)localBranchVersion {
    NSString *log = [[NSUserDefaults standardUserDefaults] objectForKey:STLVersion];
    return  STLToString(log);
}

+ (void)saveLocalBranchVersion:(NSString *)branchVersion {
    [[NSUserDefaults standardUserDefaults] setObject:STLToString(branchVersion) forKey:STLVersion];
}


///////
+ (NSString *)localCatchLogTagKey {
    NSString *log = [[NSUserDefaults standardUserDefaults] objectForKey:STLCatchLogTagKey];
    return  STLToString(log);
}

+ (void)saveLocalCatchLogTagKey:(NSString *)tagKey {
    [[NSUserDefaults standardUserDefaults] setObject:STLToString(tagKey) forKey:STLCatchLogTagKey];
}


////////
+ (NSString *)localCatchLogURLKey {
    NSString *log = [[NSUserDefaults standardUserDefaults] objectForKey:STLCatchLogURLKey];
    return STLToString(log);
}

+ (void)saveLocalCatchLogURLKey:(NSString *)urlKey {
    [[NSUserDefaults standardUserDefaults] setObject:STLToString(urlKey) forKey:STLCatchLogURLKey];
}





@end
