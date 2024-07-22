//
//  ZFSubCategoryModel.m
//  ZZZZZ
//
//  Created by YW on 2018/12/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFSubCategoryModel.h"
#import "CategoryNewModel.h"
#import "NSDictionary+SafeAccess.h"

@implementation ZFCateBanner

+ (instancetype)initWithDic:(NSDictionary *)dic {
    if (dic.count == 0) {
        return [ZFCateBanner new];
    }
    ZFCateBanner *banner = [ZFCateBanner new];

    banner.bannerCountDown = [dic ds_integerForKey:@"bannerCountDown"];
    banner.height          = [dic ds_floatForKey:@"height"];
    banner.image           = [dic ds_stringForKey:@"image"];
    banner.isShowCountDown = [dic ds_boolForKey:@"isShowCountDown"];
    banner.name            = [dic ds_stringForKey:@"name"];
    banner.url             = [dic ds_stringForKey:@"url"];
    banner.width           = [dic ds_floatForKey:@"width"];
    
    return banner;
}

@end

@implementation ZFCateBranchBanner

@end


@implementation ZFSubCategoryModel

+ (instancetype)initWithDic:(NSDictionary *)dic {
    if (dic.count == 0) {
        return [ZFSubCategoryModel new];
    }
    ZFSubCategoryModel *model = [ZFSubCategoryModel new];
    model.cateModelArray      = [NSMutableArray new];
    model.branchBannerArray   = [NSMutableArray new];
    // 解析banner
    NSArray *branchBannerDics = [dic ds_arrayForKey:@"bannerArray"];
    for (NSDictionary *branchDic in branchBannerDics) {
        if (branchDic.count == 0) {
            continue;
        }
        
        ZFCateBranchBanner *branchBanner = [[ZFCateBranchBanner alloc] init];
        branchBanner.branch              = [branchDic ds_integerForKey:@"branch"];
        branchBanner.bannerArray         = [NSMutableArray new];
        
        NSArray *bannerDics = [branchDic ds_arrayForKey:@"banners"];
        for (NSDictionary *bannerDic in bannerDics) {
            ZFCateBanner *bannerModel = [ZFCateBanner initWithDic:bannerDic];
            [branchBanner.bannerArray addObject:bannerModel];
        }
        
        if (branchBanner.bannerArray.count > 0) {
            [model.branchBannerArray addObject:branchBanner];
        }
    }
    
    // 解析分类
    NSArray *cateDics = [dic ds_arrayForKey:@"categories"];
    for (NSDictionary *cateDic in cateDics) {
        CategoryNewModel *cateModel = [CategoryNewModel instanceWithDic:cateDic];
        [model.cateModelArray addObject:cateModel];
    }
    
    return model;
}

- (BOOL)isEmpty {
    return (self.cateModelArray.count == 0 && self.branchBannerArray.count == 0);
}

@end
