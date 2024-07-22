//
//  CouponItemViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFTitleTableViewCell.h"
#import "ZFAccountProductCell.h"

@class ZFGoodsModel;

typedef NS_ENUM(NSInteger) {
    CouponListContentType_CouponList,        //coupon列表
    CouponListContentType_RecommendList      //推荐商品列表
}CouponListContentType;

static NSString *const kZFCouponListProductCellIdentifier = @"kZFCouponListProductCellIdentifier";
static NSString *const kZFCouponListTitleCellIdentifier = @"kZFCouponListTitleCellIdentifier";

typedef void(^RecommentGoodsClickBlock)(ZFGoodsModel *goodsModel);

@interface CouponItemViewModel : BaseViewModel<UITableViewDataSource,UITableViewDelegate,ZFAccountProductCellDelegate>
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, assign) CouponListContentType contentType;
@property (nonatomic, strong) NSArray *recommendDataList;
@property (nonatomic, copy) RecommentGoodsClickBlock goodsClickBlock;

- (void)requestCouponItemPageData:(BOOL)isFirstPage
                       completion:(void (^)(NSDictionary *pageInfo))completion;

@end
