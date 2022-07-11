//
//  OSSVMyGoodReviewItemsVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVReviewssGoodssTableView.h"


@class OSSVMyGoodReviewItemsVC;
@protocol STLMyGoodsReviewItemCtrlDelegate<NSObject>

- (void)STL_MyGoodsReviewItemViewController:(OSSVMyGoodReviewItemsVC *)goodsReviewController refresh:(BOOL)refresh;

@end

@interface OSSVMyGoodReviewItemsVC : STLBaseCtrl

@property (nonatomic, weak) id<STLMyGoodsReviewItemCtrlDelegate>     myDelegate;
@property (nonatomic, assign) NSInteger                             type;
@property (nonatomic, strong) OSSVReviewssGoodssTableView               *reviewsTableView;

- (void)refreshData;
@end
