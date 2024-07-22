//
//  ZFSubCategoryModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/6.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>
#import "CategoryDataManager.h"

@interface ZFCateBanner : NSObject<YYModel>

@property (nonatomic, assign) NSInteger bannerCountDown;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) BOOL isShowCountDown;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGFloat width;

+ (instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface ZFCateBranchBanner : NSObject

@property (nonatomic, strong) NSMutableArray<ZFCateBanner *> *bannerArray;
@property (nonatomic, assign) NSInteger branch;

@end

@interface ZFSubCategoryModel : NSObject

@property (nonatomic, strong) NSMutableArray<ZFCateBranchBanner *> *branchBannerArray;
@property (nonatomic, strong) NSMutableArray<CategoryNewModel *> *cateModelArray;
+ (instancetype)initWithDic:(NSDictionary *)dic;
- (BOOL)isEmpty;

@end

