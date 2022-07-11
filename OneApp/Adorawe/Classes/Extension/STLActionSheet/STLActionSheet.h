//
//  STLActionSheet.h
//  STLActionSheet
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2016年 huangxieyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSizeDidSelectProtoCol.h"


@class OSSVDetailsBaseInfoModel;
@interface STLActionSheet : UIView <OSSVSizeDidSelectProtocol>

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

@property (nonatomic, strong) NSMutableDictionary                  *analyticsDic;
@property (nonatomic, strong) NSMutableDictionary                  *gaAnalyticsDic;

//0元商品是否已经加购
@property (nonatomic, assign) NSInteger                            cart_exits;
@property (nonatomic, strong) NSString                             *screenGroup; //GA 来源
@property (nonatomic, strong) NSString                             *position; //GA 来源


@property (nonatomic, copy) void (^attributeBlock)(NSString *goodsId,NSString *wid);
@property (nonatomic, copy) void (^attributeNewBlock)(NSString *goodsId,NSString *wid,NSString *specialId);
@property (nonatomic, copy) void (^attributeHadManualSelectSizeBlock)(void);
@property (nonatomic, copy) void (^cancelViewBlock)();
@property (nonatomic, copy) void (^zeroStockBlock)(NSString *goodsId,NSString *wid);
@property (nonatomic, copy) void (^addCartEventBlock)(BOOL flag);
@property (nonatomic, copy) void (^goNewToDetailBlock)(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl);
@property (nonatomic, copy) void (^collectionStateBlock)(BOOL isCollection, NSString *wishCount);

@property (assign,nonatomic) BOOL showCollectButton;

- (void)addCartAnimationTop:(CGFloat)top moveLocation:(CGRect)location showAnimation:(BOOL)isAddAnimation;

- (void)buyItNow;
-(void)shouAttribute;

- (void)dismiss;



@end
