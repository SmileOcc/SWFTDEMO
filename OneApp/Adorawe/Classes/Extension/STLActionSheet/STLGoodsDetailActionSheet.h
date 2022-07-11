//
//  STLGoodsDetailActionSheet.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSizeDidSelectProtoCol.h"

NS_ASSUME_NONNULL_BEGIN

@class ColorSizePickView;

@class OSSVDetailsBaseInfoModel,OSSVSearchingModel;

@interface STLGoodsDetailActionSheet : UIView <OSSVSizeDidSelectProtocol>

@property (nonatomic, strong) OSSVDetailsBaseInfoModel      *baseInfoModel;
@property (nonatomic, assign) GoodsDetailEnumType                  type;
/** 记录用户购买的数量*/
@property (nonatomic, assign) NSInteger                            goodsNum;
/** 新人用户 标示*/
@property (nonatomic, assign) BOOL                                 isNewUser;
@property (nonatomic, copy) NSString                               *specialId;

@property (nonatomic, copy) NSString                               *goodsId;
@property (nonatomic, copy) NSString                               *wid;

//统计来源
@property (nonatomic, assign) STLAppsflyerGoodsSourceType          sourceType;
@property (nonatomic,copy) NSString                                *reviewsId;

@property (nonatomic, assign) BOOL                                 hadManualSelectSize;
@property (nonatomic, assign) BOOL                                 hasFirtFlash;
@property (nonatomic, assign) BOOL                                 isListSheet;

//是否快速加购
@property (nonatomic, assign) NSInteger                            addCartType;
//0元商品是否已经加购
@property (nonatomic, assign) NSInteger                            cart_exits;

@property (nonatomic, strong) NSMutableDictionary                  *analyticsDic;

///从搜索进来的关键字
@property (nonatomic,copy) NSString *searchKey;
///从搜索进来的索引
@property (nonatomic,assign) NSInteger searchPositionNum;
@property (nonatomic, strong) OSSVSearchingModel *searchModel;


@property (nonatomic, copy) void (^attributeBlock)(NSString *goodsId,NSString *wid);
@property (nonatomic, copy) void (^attributeHadManualSelectSizeBlock)(void);
@property (nonatomic, copy) void (^cancelViewBlock)();
@property (nonatomic, copy) void (^zeroStockBlock)(NSString *goodsId,NSString *wid);
@property (nonatomic, copy) void (^addCartEventBlock)(BOOL flag);
@property (nonatomic, copy) void (^goToDetailBlock)(NSString *goodsId, NSString *wid);
@property (nonatomic, copy) void (^collectionStateBlock)(BOOL isCollection, NSString *wishCount);

@property (assign,nonatomic) BOOL showCollectButton;

- (void)addCartAnimationTop:(CGFloat)top moveLocation:(CGRect)location showAnimation:(BOOL)isAddAnimation;

- (void)buyItNow;
-(void)shouAttribute;

- (void)dismiss;

@property (nonatomic, strong) ColorSizePickView          *colorSizePickView;

@end

NS_ASSUME_NONNULL_END
