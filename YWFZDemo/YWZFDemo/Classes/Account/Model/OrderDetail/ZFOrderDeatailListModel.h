//
//  ZFOrderDeatailListModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderDetailGoodModel.h"
#import "OrderDetailOrderModel.h"

@interface ZFChildOrderInfoModel : NSObject
@property (nonatomic, copy) NSString *warehouse_msg;
@property (nonatomic, copy) NSString *order_sn;
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *order_status;
@property (nonatomic, copy) NSString *show_refund;
@property (nonatomic, copy) NSString *order_status_str;
@end


@interface ZFOrderDetailChildModel : NSObject
@property (nonatomic, strong) NSArray<OrderDetailGoodModel *> *goods_list;
@property (nonatomic, strong) ZFChildOrderInfoModel *order_info;
@end


@interface ZFRefundOrderModel : NSObject
@property (nonatomic, copy) NSString *tk_page_url;
@property (nonatomic, copy) NSString *order_sn;
@property (nonatomic, copy) NSString *order_status;
@end

@interface ZFRefundReasonModel : NSObject
@property (nonatomic, copy) NSString *parent;
@property (nonatomic, copy) NSString *reasonId;
@property (nonatomic, copy) NSString *reason;
//是否用户自述原因
@property (nonatomic, assign) BOOL otherReason;
@end


@interface ZFOrderDeatailListModel : NSObject
//@property (nonatomic, strong) OrderDetailOrderModel                     *order;
//@property (nonatomic, strong) NSMutableArray<OrderDetailGoodModel *>    *goods_list;


//------拆单新改版Model---------
@property (nonatomic, strong) NSString                                  *not_paying_order;
@property (nonatomic, strong) OrderDetailOrderModel                     *main_order;
@property (nonatomic, strong) NSArray<ZFOrderDetailChildModel *>        *child_order;
@property (nonatomic, strong) NSArray<ZFRefundOrderModel *>             *refund_order_list;
///用户退款原因数据
@property (nonatomic, strong) NSArray<ZFRefundReasonModel *>            *refund_select_info;

///订单详情显示的社区 banner图片 url,
@property (nonatomic, copy) NSString                                    *orderTopicImageUrl;
///订单详情显示的社区 banner id,
@property (nonatomic, copy) NSString                                    *orderTopicId;

@property (nonatomic, assign) NSInteger                                 totalGoodsNums;

@end
