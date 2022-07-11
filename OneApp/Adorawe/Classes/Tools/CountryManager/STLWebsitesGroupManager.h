//
//  STLWebsitesGroupManager.h
//  Adorawe
//
//  Created by odd on 2021/9/27.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateModel.h"

@class STLWebitesModel;
@class STLWebitesCountryModel;
@class STLWebsitesGroupModel;

//站点支持域名管理
@interface STLWebsitesGroupManager : NSObject

@property (nonatomic, strong) STLWebsitesGroupModel           *websitesGroupModel;
@property (nonatomic, strong) STLWebitesModel                 *currentWebsitesModel;

//APP里现在不能切换，就先这边保存了
@property (nonatomic, strong) STLWebitesCountryModel            *defaultCountryModel;

+ (STLWebsitesGroupManager *)sharedManager;

- (void)handCurrentWebSites;

+ (NSString *)defaultCountryCode;

///当前国家站点
+ (NSString *)currentCountrySiteCode;
///当前国家站域名
+ (NSString *)currentCountrySiteDomain;
///是否已经成功获取站点域名
+ (BOOL)hasWebsitesData;

@end


//站点支持域名
@interface STLWebsitesGroupModel : NSObject
@property (nonatomic, strong) NSArray<STLWebitesModel*>   *websites;
@end

@interface STLWebitesModel : NSObject

@property (nonatomic, copy) NSString *site_group;
@property (nonatomic, copy) NSString *site_code;
@property (nonatomic, copy) NSString *api_domain;
@property (nonatomic, assign) NSInteger is_default;

@property (nonatomic, strong) NSArray<RateModel*>               *currencies;
@property (nonatomic, strong) NSArray<OSSVSupporteLangeModel*>     *langs;
@property (nonatomic, strong) NSArray<STLWebitesCountryModel*>  *countries;


@end


@interface STLWebitesCountryModel : NSObject

@property (nonatomic, copy) NSString *country_code;
@property (nonatomic, copy) NSString *country_en;
@property (nonatomic, assign) NSInteger is_default;

@end

