//
//  ZFCommunityOutfitRefineSectionModel.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>


///////////////////

@interface ZFOutfitRefineCellModel : NSObject

/**
 * 属性id
 */
@property (nonatomic, copy) NSString   *attrID;

/**
 * 属性名
 */
@property (nonatomic, copy) NSString   *name;

/**
 * 标记已选的属性
 */
@property (nonatomic, assign) BOOL   isSelect;

@end


////////////////////

@interface ZFOutfitRefineDetailModel : NSObject
/**
 * 属性类名
 */
@property (nonatomic, copy)   NSString                               *name;
/**
 * 所有属性集合
 */
@property (nonatomic, strong) NSArray<ZFOutfitRefineCellModel *>     *childArray;

/**
 * 记录是否展开,默认关闭
 */
@property (nonatomic, assign) BOOL                                   isExpend;

/**
 * 已选属性名称集合
 */
//@property (nonatomic, strong) NSMutableArray                         *selectArray;


/**
 * 上传属性集合
 */
@property (nonatomic, strong) NSMutableArray                         *attrsArray;


@end


@interface ZFCommunityOutfitRefineSectionModel : NSObject

@property (nonatomic, strong) NSArray<ZFOutfitRefineDetailModel *>     *refine_list;
@property (nonatomic, copy)   NSString                                 *priceMax;
@property (nonatomic, copy)   NSString                                 *priceMin;
@property (nonatomic, copy)   NSString                                 *selectPriceMin;
@property (nonatomic, copy)   NSString                                 *selectPriceMax;

@end

