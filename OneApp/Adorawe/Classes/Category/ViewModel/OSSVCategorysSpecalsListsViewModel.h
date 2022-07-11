//
//  OSSVCategorysSpecalsListsViewModel.h
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVCategorysNewZeroListVC.h"
#import "OSSVThemeZeroPrGoodsModel.h"
#import "OSSVHomeCThemeModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^freeBtnBlock)(OSSVThemeZeroPrGoodsModel *zerModel);

@interface OSSVCategorysSpecalsListsViewModel : BaseViewModel<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDelegate,UICollectionViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) OSSVCategorysNewZeroListVC   *controller;

@property (nonatomic, strong) NSMutableArray                   *dataArray;
@property (nonatomic, copy) NSString                           *name;
@property (nonatomic, strong) NSMutableDictionary              *analyticDic;
@property (nonatomic, assign) BOOL                             isFromZeroYuan; //是否来源0元专题
@property (nonatomic, strong) OSSVHomeCThemeModel               *themeModel;

@property (nonatomic, copy) freeBtnBlock                       freeBtnblock;

// 快速加购方式
- (void)requesData:(NSString*)goodsId wid:(NSString*)wid;

// 0元商品快速加购
- (void)requesData:(NSString*)goodsId wid:(NSString*)wid withSpecialId:(NSString *)specialId;

@end

NS_ASSUME_NONNULL_END
