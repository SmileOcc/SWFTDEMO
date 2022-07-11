//
//  OSSVReviewssGoodssTableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVReviewssGoodssCell.h"
@class OSSVReviewssGoodssTableView;

@protocol STLReviewsGoodsTableViewDelegate<NSObject>

- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView selectIndexPath:(NSIndexPath *)indexPath;
- (void)STL_ReviewsGoodsTableView:(OSSVReviewssGoodssTableView *)tableView refresh:(BOOL)refresh;
@end

@interface OSSVReviewssGoodssTableView : UITableView<UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) id<STLReviewsGoodsTableViewDelegate>    myDelegate;

@property (nonatomic, strong) NSMutableArray                       *goodsDatas;
@property (nonatomic,assign) NSInteger dataType;

@end
