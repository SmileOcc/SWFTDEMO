//
//  STLDiscoveryBlockModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>


@class STLDiscoveryBlockSlideGoodsModel;

@interface OSSVDiscoverBlocksModel : NSObject

@property (nonatomic, strong) OSSVAdvsEventsModel            *banner;
@property (nonatomic, strong) NSArray<OSSVAdvsEventsModel*>  *images;
@property (nonatomic, copy) NSString                      *type;
@property (nonatomic, strong) NSArray<STLDiscoveryBlockSlideGoodsModel*> *slide_data;

////自定义
@property (nonatomic, strong) OSSVAdvsEventsModel            *emptyBanner;
@property (nonatomic, strong) STLAdvEventSpecialModel     *specialModelBanner;
////自定义 (type=101)滑动组件商品图片比例 3/4  或1/1 默认3/4
@property (nonatomic, assign) CGFloat                     imageScale;

@end



@interface STLDiscoveryBlockSlideGoodsModel : STLGoodsBaseModel

//图片
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, copy) NSString *goods_original;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *special_id;
@property (nonatomic, copy) NSString *wid;
@property (nonatomic, copy) NSString *goods_id;

//自定义
@property (nonatomic, copy) NSAttributedString *lineMarketPrice;

@end
