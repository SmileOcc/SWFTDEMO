//
//  OSSVOrdersReviewVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVOrdersReviewsTableView.h"


@class OSSVOrdersReviewVC;
@protocol STLOrderReviewCtrlDelegate<NSObject>

- (void)STL_OrderReviewViewController:(OSSVOrdersReviewVC *)orderReviewController refresh:(BOOL)refresh;

@end

@interface OSSVOrdersReviewVC : STLBaseCtrl<STLOrderReviewTableViewDelegate>

@property (nonatomic, weak) id<STLOrderReviewCtrlDelegate>              myDelegate;
@property (nonatomic, strong) OSSVOrdersReviewsTableView                  *reviewsTableView;
@property (nonatomic, strong) UIView                                    *emptyView;
@property (nonatomic, copy) NSString  *orderId;

@end
