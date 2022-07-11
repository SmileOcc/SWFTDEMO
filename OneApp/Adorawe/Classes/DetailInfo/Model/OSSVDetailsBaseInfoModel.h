//
//  OSSVDetailsBaseInfoModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVDetailPictureArrayModel.h"
#import "OSSVSizeChartModel.h"
#import "STLGoodsBaseModel.h"
#import "OSSVTransportTimeModel.h"
#import "OSSVDetailServiceTipModel.h"

@class OSSVDetailNowAttributeModel;
@class STLProductsDetailStoreBaseInfoModel;
@class STLProductsDetailsChangeAttributeModel;
@class OSSVBundleActivityModel;
@class OSSVAttributeItemModel;
@class OSSVSpecsModel;
@class OSSVTipsInfoModel;
@class OSSVCoinDescModel;

@interface OSSVDetailsBaseInfoModel : STLGoodsBaseModel

@property (nonatomic,copy) NSString *goodsSmallImg;
@property (nonatomic,copy) NSString *goodsImg;
@property (nonatomic,copy) NSString *goodsBigImg;
//短名称
@property (nonatomic,copy) NSString *goodsUrlTitle;
@property (nonatomic,copy) NSString *goodsGroupId; ////

//供应商编号
@property (nonatomic,copy) NSString *goodsSupplierCode;
@property (nonatomic,copy) NSString *goodsDiscount;
@property (nonatomic,copy) NSString *showDiscountIcon;
//仓库
@property (nonatomic,copy) NSString *goodsWid;

//市场价
@property (nonatomic,copy) NSString *goodsMarketPrice;
//用与缓存
@property (nonatomic,copy) NSString *shop_price_origin;
@property (nonatomic,copy) NSString *goodsNumber;
@property (nonatomic,copy) NSString *goodsAttr;

@property (nonatomic,assign) BOOL   isOnSale;
@property (nonatomic,assign) BOOL   isCollect;

///自定义
@property (nonatomic,copy) NSString *free_goods_exists;

//整个spu下的商品数量
@property (nonatomic, copy) NSString *spuGoodsNumber;
//spu下是否全部下架
@property (nonatomic, copy) NSString *spuOnSale;

//商品描述
@property (nonatomic,copy) NSString         *urlmdesc;
//比PC节省了多少钱
@property (nonatomic,copy) NSString         *appSavePrice;
@property (nonatomic,strong) NSArray<OSSVDetailPictureArrayModel*>        *pictureListArray;

@property (nonatomic,strong) NSArray <OSSVBundleActivityModel*>              *bundleActivity;
@property (nonatomic,copy) NSString                              *urlShare;
// 多属性数组
@property (nonatomic,strong) NSArray<OSSVSpecsModel*>        *GoodsSpecs;
// size尺码描述
@property (nonatomic,strong) NSArray <OSSVSizeChartModel *>      *size_info;
// 当前商品默认属性
//@property (nonatomic,copy) NSString                              *GoodsSpecsNames;

/** 商详页-COD免邮提示语*/
@property (nonatomic,copy) NSString                              *codFreeShippingTip;

@property (nonatomic, copy) NSString                             *wishCount;

@property (nonatomic, strong) NSArray<OSSVTipsInfoModel*>    *tips_info;  //不用了

@property (nonatomic, assign) CGFloat                            goodsSizeHeight;

//屏蔽状态 0正常  1已屏蔽 【1.16】
@property (nonatomic, copy) NSString                             *shield_status;
@property (nonatomic, copy) NSString                             *shield_tips;
@property (nonatomic, copy) NSString                             *top_cat_id;
@property (nonatomic, copy) NSString                             *top_cat_name;

@property (nonatomic, strong) OSSVTransportTimeModel   *transportTimeModel; //运输时长model
@property (nonatomic, strong) NSArray <OSSVDetailServiceTipModel *>       *serviceTipModel;    //服务信息model

// 商详页金币
@property (nonatomic, assign) NSInteger                          return_coin;// 返回金币数量
@property (nonatomic, strong) OSSVCoinDescModel              *return_coin_desc;// 金币描述
 

////自定义
@property (nonatomic, assign) NSInteger   detailSourceType;
@property (nonatomic, assign) CGFloat     maxBundleActivityWidth;
@property (nonatomic, assign) BOOL        isHasSizeItem;// 返回的数据可能没有尺寸数据
@property (nonatomic, assign) BOOL        isHasColorItem;// 返回的数据可能没有颜色数据

@property (nonatomic, assign) BOOL        isShowTitleMore;
@property (nonatomic, assign) BOOL        isShowLess;
@property (nonatomic, assign) CGFloat     titleSizeHeight;
@property (nonatomic, assign) CGFloat     titleLessSizeHeight;
@property (nonatomic, copy) NSAttributedString *titleAttributeString;

- (NSMutableAttributedString *)selectSizeDesc:(NSString *)selectSize;

- (OSSVSpecsModel *)goodsChartSizeUrl;

- (BOOL)isGoodsDetailDiscountOrFlash;

@end


//满减信息
@interface OSSVBundleActivityModel : NSObject

//满减调整url
@property (nonatomic,copy) NSString      *bundledSpecialUrl;
//满减调整提示
@property (nonatomic,copy) NSString     *discountRange;
@property (nonatomic,copy) NSString     *activeId;
@property (nonatomic,copy) NSString     *activeName;

//去掉html格式的提示
@property (nonatomic,copy) NSString      *discountDesc;

@property (nonatomic,strong) UIImage     *descountImg;

@property (nonatomic,assign) CGFloat     maxContentWidth;
///自定义
@property (nonatomic,copy) NSAttributedString *discountRangeAttribute;
@end




@interface OSSVSpecsModel : NSObject

@property (nonatomic,copy) NSArray <OSSVAttributeItemModel*>      *brothers;
@property (nonatomic,copy) NSString      *spec_name;
///1 color  2 size
@property (nonatomic,copy) NSString      *spec_type;
@property (nonatomic,copy) NSString      *size_chart_title;
@property (nonatomic,copy) NSString      *size_chart_url;

///自定义
@property (nonatomic,assign) BOOL        hasSelectSpecs;

@property (nonatomic,assign) BOOL        isSelectSize;

- (NSString *)goodsChartSizeUrl;

@end

@interface OSSVAttributeItemModel : NSObject

@property (nonatomic, assign) BOOL       checked;
@property (nonatomic, assign) BOOL       disabled;
@property (nonatomic,copy) NSString      *attr_id;
@property (nonatomic,strong) NSArray     *group_goods_id;
@property (strong,nonatomic) NSArray<NSDictionary *>     *disable_state;
@property (nonatomic,copy) NSString      *attr_desc;
@property (nonatomic,copy) NSString      *wid;
///属性多文案显示
@property (nonatomic,copy) NSString      *value;
///属性英文显示
@property (nonatomic,copy) NSString      *size_name;
/// 0 是颜色 1 是尺码，与上面有差异
@property (nonatomic,copy) NSString      *type;
@property (nonatomic,copy) NSString      *goods_id;
@property (nonatomic,copy) NSString      *goods_thumb;
@property (nonatomic,copy) NSString      *goods_number;
@property (nonatomic,assign) NSInteger   is_hot;

///保存当前属性商品数量
@property (strong,nonatomic) NSNumber * _Nullable goodsNumber;
///保存当前属性是否在售
@property (strong,nonatomic) NSNumber * _Nullable isOnSale;

///当前国际尺码
@property (copy,nonatomic) NSString*  sizeLocalName;



@end



@interface OSSVTipsInfoModel : NSObject

@property (nonatomic,copy) NSString      *content;
@property (nonatomic,assign) NSInteger   position;

@end

@interface OSSVCoinDescModel : NSObject

@property (nonatomic,copy) NSString       *return_coin;
@property (nonatomic,copy) NSString       *about_coin;
@property (nonatomic,strong) NSArray      *desc_list;


@end
