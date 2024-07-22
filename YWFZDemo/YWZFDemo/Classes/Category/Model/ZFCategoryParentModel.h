//
//  ZFCategoryParentModel.h
//  ZZZZZ
//
//  Created by YW on 2019/3/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZFSubCategoryModel_GoodsType = 201,     //201:商品Item  子分类
    ZFSubCategoryModel_BannerType = 203,    //203:通栏Banner  子分类头部
} ZFSubCategoryModelType;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCategoryAttributes : NSObject
@property (nonatomic, copy)   NSString *color;
@property (nonatomic, copy)   NSString *fontSize;
@end

@interface ZFCategoryTabContainer : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy)   NSString *actionType;
@property (nonatomic, copy)   NSString *actionUrl;
@property (nonatomic, copy)   NSString *img;
@property (nonatomic, copy)   NSString *imgWidth;
@property (nonatomic, copy)   NSString *imgHeight;
@property (nonatomic, copy)   NSString *imgName;
@property (nonatomic, copy)   NSString *tabContainerId;
@property (nonatomic, copy)   NSString *clientType;
@property (nonatomic, copy)   NSString *text; //名称
@property (nonatomic, strong) ZFCategoryAttributes *attributes;
@property (nonatomic, copy)   NSString *name; //暂时没用到
@property (nonatomic, assign) NSInteger isAutoReplace;//暂时没用到
@property (nonatomic, strong) NSArray *categoryIds;// 所属的分类id，可能有多个，也可能为空
@property (nonatomic, strong) NSArray *categoryNames;// 所属的分类名称，可能有多个，也可能为空
@end

@interface ZFCategoryTabNav : NSObject
@property (nonatomic, assign) NSInteger tabNavId;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, strong) ZFCategoryAttributes *attributes;
@end


@interface ZFCategoryParentModel : NSObject
@property (nonatomic, copy)   NSString *parentId;
@property (nonatomic, strong) ZFCategoryTabNav *TabNav;
@property (nonatomic, strong) NSArray<ZFCategoryTabContainer *> *TabContainer;
@end


@interface ZFSubCategorySectionModel : NSObject
@property (nonatomic, assign) ZFSubCategoryModelType sectionType;
@property (nonatomic, strong) NSMutableArray<ZFCategoryTabContainer *> *sectionModelarray;
@property (nonatomic, assign) CGSize sectionItemSize;
@end


NS_ASSUME_NONNULL_END
