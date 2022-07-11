//
//  OSSVPayTotalTableViewCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  商品合计cell

#import <UIKit/UIKit.h>
#import "OSSVTableViewCellProtocol.h"
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVCartCheckModel.h"
#import "OSSVTotalDetailCellModel.h"
#import "OSSVCartOrderInfoViewModel.h"

#pragma mark - OSSVPayTotalTableViewCell
@class STLPayTotalCellModel;
@protocol STLPayTotalCellDelegate <TableViewCellDelegate>

-(void)STLPrdTotalDidClick:(STLPayTotalCellModel *)model;

@end

@interface OSSVPayTotalTableViewCell : UITableViewCell
<
OSSVTableViewCellProtocol
>

@property (nonatomic, weak) id<STLPayTotalCellDelegate>delegate;

@end


#pragma mark - STLPrdTotalCellModel

@interface STLPayTotalCellModel : NSObject
<
OSSVBaseCellModelProtocol
>
///index，用户取数据的时候，从数据池wareHouseList里
@property (nonatomic, assign) NSInteger index;
///<依赖关系模型
@property (nonatomic, strong) NSMutableArray *dependModelList;
///<依赖关系的数组模型在表里面的区间
@property (nonatomic, assign) NSRange detailRange;
///<显示总价格
@property (nonatomic, copy) NSString *totalPrice;
///<是否正在显示总数详情 YES 正在显示 NO 隐藏
@property (nonatomic, assign) BOOL isShowingDetail;
///<是否需要隐藏整行 YES 隐藏 NO 显示
@property (nonatomic, assign) BOOL isHiddenCell;
#pragma mark - 数据源
@property (nonatomic, strong) OSSVCartOrderInfoViewModel *dataSourceModel;

/**
 *  处理小计价格列表
 *  dataSource => tableview datasource array
 */
-(void)handleTotalListDetailWithDataSoruce:(NSMutableArray *)dataSource;

@end
