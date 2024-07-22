//
//  ZFNativeBannerResultModel.m
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeBannerResultModel.h"

@implementation ZFNativeBannerResultModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"infoModel"       : @"specialInfo",
             @"bannerList"      : @"positionList",
             @"plateGoodsArray" : @"goodsList",
             @"menuList"        : @"navigationList"
            };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bannerList"         : [ZFNativeBannerListModel class],
             @"plateGoodsArray"    : [ZFNativePlateGoodsModel class],
             @"menuList"           : [ZFNativeBannerPageModel class]
             };
}

- (CGFloat)calculateAllBranchHeight {
    self.allbannerHeight = 0.f;
//    self.bannerCount = self.banner_list.count;
//    for (ZFNativeBannerListModel *bannerListModel in self.banner_list) {
//        if ([bannerListModel.branchType integerValue] == 1) {
//            for (ZFBannerModel *model in bannerListModel.bannerList) {
//                CGFloat bannerHeight = [model.banner_height floatValue] * 0.5 * ScreenWidth_SCALE;
//                self.allbannerHeight += bannerHeight;
//
//            }
//        } else {
//            NSInteger count = (bannerListModel.bannerList.count / [bannerListModel.branchType integerValue]) +
//            (bannerListModel.bannerList.count % [bannerListModel.branchType integerValue] != 0);
//            self.allbannerHeight += (count * [bannerListModel.bannerList.firstObject.banner_height floatValue] * 0.5 * ScreenWidth_SCALE);
//        }
//    }
//    self.allbannerHeight = ceil(self.allbannerHeight);
    return self.allbannerHeight;
}


@end

