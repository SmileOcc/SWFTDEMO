//
//  ZFSizeSelectItemsModel.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFSizeSelectItemType) {
    ZFSizeSelectItemTypePrice = 0,
    ZFSizeSelectItemTypeColor,
    ZFSizeSelectItemTypeSize,
    ZFSizeSelectItemTypeMultAttr,
    ZFSizeSelectItemTypeLiveRecommendTry
};

@interface ZFSizeSelectItemsModel : NSObject

@property (nonatomic, assign) ZFSizeSelectItemType          type;
@property (nonatomic, copy) NSString                        *attrName;
@property (nonatomic, copy) NSString                        *color;
@property (nonatomic, copy) NSString                        *color_img;
@property (nonatomic, assign) BOOL                          is_click;
@property (nonatomic, copy) NSString                        *goodsId;
@property (nonatomic, assign) CGFloat                       width;
@property (nonatomic, assign) BOOL                          isSelect;
@end
