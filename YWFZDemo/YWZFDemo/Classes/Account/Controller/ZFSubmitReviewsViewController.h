//
//  ZFSubmitReviewsViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFSubmitReviewsViewController : ZFBaseViewController

@property (nonatomic, strong) NSMutableArray         *selectedPhotos;
@property (nonatomic, strong) NSMutableArray         *selectedAssets;
@property (nonatomic, copy)   NSString               *orderId;
@property (nonatomic, copy) NSString *goodsId;

@end
