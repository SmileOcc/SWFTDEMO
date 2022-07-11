//
//  STLWebsitesGroupManager.m
//  Adorawe
//
//  Created by odd on 2021/9/27.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLWebsitesGroupManager.h"


@implementation STLWebsitesGroupManager

+ (STLWebsitesGroupManager *)sharedManager {
    static STLWebsitesGroupManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

+ (NSString *)defaultCountryCode {
    if ([STLWebsitesGroupManager sharedManager].defaultCountryModel) {
        return STLToString([STLWebsitesGroupManager sharedManager].defaultCountryModel.country_code);
    }
    return @"";
}

+ (NSString *)currentCountrySiteCode {
    if ([STLWebsitesGroupManager sharedManager].currentWebsitesModel) {
        return STLToString([STLWebsitesGroupManager sharedManager].currentWebsitesModel.site_code);
    }
    return @"";
}

+ (NSString *)currentCountrySiteDomain {
    if ([STLWebsitesGroupManager sharedManager].currentWebsitesModel) {
        NSString *domainUrl = STLToString([STLWebsitesGroupManager sharedManager].currentWebsitesModel.api_domain);
        
        if (![domainUrl hasSuffix:@"/"]) {
            domainUrl = [NSString stringWithFormat:@"%@/",domainUrl];
        }
        return domainUrl;
    }
    
    return @"";
}

+ (BOOL)hasWebsitesData {
    if ([STLWebsitesGroupManager sharedManager].currentWebsitesModel && !STLIsEmptyString([STLWebsitesGroupManager sharedManager].currentWebsitesModel.api_domain)) {
        return YES;
    }
    return NO;
}

- (void)handCurrentWebSites {
    if (self.websitesGroupModel && STLJudgeNSArray(self.websitesGroupModel.websites)) {
        [self.websitesGroupModel.websites enumerateObjectsUsingBlock:^(STLWebitesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.is_default == 1) {
                self.currentWebsitesModel = obj;
                *stop = YES;
            }
        }];
    }
    
    if (self.currentWebsitesModel && STLJudgeNSArray(self.currentWebsitesModel.countries)) {
        [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"national" : STLToString(self.currentWebsitesModel.site_code)}];
        [FIRAnalytics setUserPropertyString:STLToString(self.currentWebsitesModel.site_code) forName:@"country_code"];
        [self.currentWebsitesModel.countries enumerateObjectsUsingBlock:^(STLWebitesCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.is_default == 1) {
                self.defaultCountryModel = obj;
                *stop = YES;
            }
        }];
    }
    
    

    //后台语言
    NSArray *languages = !STLJudgeEmptyArray(self.currentWebsitesModel.langs) ? self.currentWebsitesModel.langs : @[];
    //后台货币
    NSArray *rates = !STLJudgeEmptyArray(self.currentWebsitesModel.currencies) ? self.currentWebsitesModel.currencies : @[];

    //语言设置处理
    [STLLocalizationString handInitSupporLang:languages];
    //货币设置处理
    [ExchangeManager handInitCurrencyData:rates];
    
//    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
//    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
//        addSTLLinkCookie();
//    }
    //切换语言后切换系统UI布局方式
    [UIViewController convertAppUILayoutDirection];
}

@end

@implementation STLWebsitesGroupModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"websites"          : [STLWebitesModel class],
             };
}

@end


@implementation STLWebitesModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"currencies"          : [RateModel class],
             @"langs"               : [OSSVSupporteLangeModel class],
             @"countries"           : [STLWebitesCountryModel class],
             };
}
@end

@implementation STLWebitesCountryModel

@end
