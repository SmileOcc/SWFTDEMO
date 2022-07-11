//
//  OSSVCartSelectCouponVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
/*当前ViewModel*/
#import "OSSVCartCouponItemViewModel.h"

@class OSSVCouponModel;
@class OSSVCouponApplyView;

@class OSSVCartGoodsModel,OSSVMyCouponsListsModel;

@interface OSSVCartSelectCouponVC : STLBaseCtrl 

@property (nonatomic,copy) void (^golBackBlock)(OSSVMyCouponsListsModel *model);

@property (nonatomic,strong) NSArray *cartGoodsArray;
/*应用视图*/
@property (nonatomic, strong) OSSVCouponApplyView *couponApplyView;

/*当前ViewModel*/
@property (nonatomic,strong) OSSVCartCouponItemViewModel *viewModel;

/*数据模型*/
@property (nonatomic,strong) OSSVMyCouponsListsModel *selectedModel;


@end

/*数据模型*/
@interface CartCouponSelectTempModel : NSObject

@property (nonatomic,copy) NSString *goods_id;

@property (nonatomic,assign) NSInteger goods_number;

@property (nonatomic,copy) NSString *wid;

@property (nonatomic,copy) NSString *is_flash_sale; // 是否是闪购商品

@property (nonatomic,copy) NSString *flash_sale_active_id;  //闪购活动ID

//折扣字段
@property (nonatomic,copy) NSString *goods_discount_price;

@property (nonatomic,copy) NSString *shop_price;

@property (nonatomic,copy) NSString *goods_sn;

@property (nonatomic,copy) NSString *cat_id;

@property (nonatomic,copy) NSString *is_clearance;

@property (nonatomic,copy) NSString *is_promote_price;

- (instancetype)initWithCartGoodsModel:(OSSVCartGoodsModel *)cartGoodsModel;

@end
