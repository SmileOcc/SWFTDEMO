//
//  OSSVOrdersReviewsTableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVReviewssGoodssCell.h"
#import "OSSVOrdersReviewsScoreView.h"
#import "OSSVOrdereRevieweModel.h"

@class OSSVOrdersReviewsTableView;
@protocol STLOrderReviewTableViewDelegate<NSObject>
- (void)STL_OrderReviewTableView:(OSSVOrdersReviewsTableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)STL_OrderReviewTableView:(OSSVOrdersReviewsTableView *)tableView transoprt:(CGFloat)transport goods:(CGFloat)goods pay:(CGFloat)pay service:(CGFloat)service;
@end

@interface OSSVOrdersReviewsTableView : UITableView<UITableViewDelegate,UITableViewDataSource,STLReviewsGoodsCellDelegate>

@property (nonatomic, weak) id<STLOrderReviewTableViewDelegate>     myDelegate;

@property (nonatomic, strong) OSSVOrdersReviewsScoreView                 *scoreView;

@property (nonatomic, strong) OSSVOrdereRevieweModel                     *reviewModel;

@property (nonatomic, strong) NSMutableArray                         *goodsDatas;

@property (nonatomic,copy) NSString *orderId;

- (void)reviewSuccess;

@end
