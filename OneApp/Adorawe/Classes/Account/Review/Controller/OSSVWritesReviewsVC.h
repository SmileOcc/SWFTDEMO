//
//  OSSVWritesReviewsVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVAccounteOrdersDetaileGoodsModel.h"

typedef void(^WriteReviewSuccess)(void);

@interface OSSVWritesReviewsVC : STLBaseCtrl

@property (nonatomic,strong) OSSVAccounteOrdersDetaileGoodsModel *goodsModel;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) WriteReviewSuccess block;

@end
