//
//  OSSVDetailsVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@class OSSVSearchingModel;
@interface OSSVDetailsVC : STLBaseCtrl

@property (nonatomic, copy) NSString                        *goodsId;
// warehouse id
@property (nonatomic, copy) NSString                        *wid;
// 商品封面图
@property (nonatomic, copy) NSString                        *coverImageUrl;

@property (nonatomic, assign) STLAppsflyerGoodsSourceType   sourceType;
@property (nonatomic, copy) NSString                         *reviewsId;
////0元活动
@property (nonatomic, copy) NSString                        *specialId;

@property (nonatomic, strong) YYAnimatedImageView           *transformSourceImageView;


//MARK: -搜索结果进来带的值
///从搜索进来的关键字
@property (nonatomic,copy) NSString *searchKey;
///从搜索进来的索引
@property (nonatomic,assign) NSInteger searchPositionNum;
@property (nonatomic, strong) OSSVSearchingModel *searchModel;


@property (nonatomic, copy) void (^collectionBlock)(NSString *isCollection, NSString *goodsId);

@end
