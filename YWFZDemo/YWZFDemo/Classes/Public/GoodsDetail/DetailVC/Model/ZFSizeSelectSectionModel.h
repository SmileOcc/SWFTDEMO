//
//  ZFSizeSelectSectionModel.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFSizeSelectItemsModel.h"

typedef NS_ENUM(NSInteger, ZFSizeSelectSectionType) {
    ZFSizeSelectSectionTypePrice = 0,
    ZFSizeSelectSectionTypeColor,
    ZFSizeSelectSectionTypeSize,
    ZFSizeSelectSectionTypeSizeTips,
    ZFSizeSelectSectionTypeMultAttr,
    ZFSizeSelectSectionTypeStockTips, //V4.8.0增加库存提醒一栏
    ZFSizeSelectSectionTypeLiveComment,
};

@interface ZFSizeSelectSectionModel : NSObject

@property (nonatomic, assign) ZFSizeSelectSectionType                       type;
@property (nonatomic, strong) NSMutableArray<ZFSizeSelectItemsModel *>      *itmesArray;
@property (nonatomic, copy)   NSString                                      *typeName;

//自定义
@property (nonatomic, assign) CGFloat                                       sectionHeight;

@end
