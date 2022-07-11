//
//  OSSVTransporteSpliteTotalModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//  -----拆单总数据-----

#import <Foundation/Foundation.h>
//#import "OSSVTransporteSpliteGoodsModel.h"
//#import "OSSVTrackeDetaileModel.h"
#import "OSSVTrackeListeMode.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransporteSpliteTotalModel : NSObject
@property (nonatomic, copy) NSString *track_text; //物流头部描述
//@property (nonatomic, copy) NSString *order_sn; //订单号
//@property (nonatomic, copy) NSString *flow_num; //物流单号
//@property (nonatomic, copy) NSString *track_at;
//@property (nonatomic, copy) NSString *trackId; //物流ID
//@property (nonatomic, strong) OSSVTrackeDetaileModel *trackDetail;
//@property (nonatomic, strong) NSArray<OSSVTransporteSpliteGoodsModel *> *goodsList;
@property (nonatomic, strong) NSArray<OSSVTrackeListeMode *> *trackList;
@end

NS_ASSUME_NONNULL_END
