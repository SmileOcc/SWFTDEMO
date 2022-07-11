//
//  OSSVCartBaseGoodsCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import "CartModel.h"

typedef NS_ENUM(NSInteger,CartTableCellEvent) {
    /** 未选中*/
    CartTableCellEventUnSelecte,
    /** 选中*/
    CartTableCellEventSelected,
    /** 增加*/
    CartTableCellEventIncrease,
    /** 减少*/
    CartTableCellEventReduce,
    /** 收藏*/
    CartTableCellEventCollect,
    /** 删除*/
    CartTableCellEventDelete,
};

typedef void (^EventOperateBlock)(UIButton *sender, CartTableCellEvent event);

@interface OSSVCartBaseGoodsCell : MGSwipeTableCell

@property (nonatomic, copy) EventOperateBlock     operateBlock;

@property (nonatomic,strong) CartModel          *cartModel;

//统计来源
@property (nonatomic, assign) CartGroupModelType   sourceType;

@end
