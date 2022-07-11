//
//  OSSVCartViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "MGSwipeTableCell.h"
#import "OSSVCartBottomResultView.h"

typedef NSIndexPath *(^MGSwipeCallback)(UITableViewCell *cell);
typedef void (^UpdateResultBlock)(CartInfoModel *cartPriceInfo, NSInteger count, BOOL isSelectAll);

@interface OSSVCartViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate,OSSVCartBottomResultViewDelegate>

@property (nonatomic, copy) MGSwipeCallback        swipeCallback;
@property (nonatomic, copy) UpdateResultBlock      updateResultBlock;
@property (nonatomic, weak) UIViewController       *controller;
@property (nonatomic, strong) STLCartModel          *cartModel;

@property (nonatomic, weak) OSSVCartBottomResultView  *bottomView;

- (void)cartCheckOrderAddress:(NSString *)addressid;
- (void)updateCartData:(STLCartModel *)cartModel;
- (void)buyOperationAddressId:(NSString *)addressId;
@end
