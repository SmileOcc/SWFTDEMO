//
//  OSSVTrackeListeMode.h
// XStarlinkProject
//
//  Created by Kevin on 2020/12/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVTransporteSpliteGoodsModel.h"
#import "OSSVTrackeDetaileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTrackeListeMode : NSObject
@property (nonatomic, copy) NSString *order_sn; //订单号
@property (nonatomic, copy) NSString *flow_num; //物流单号
@property (nonatomic, copy) NSString *track_at;
@property (nonatomic, copy) NSString *trackId; //物流ID

@property (nonatomic, strong) OSSVTrackeDetaileModel *trackDetail;
@property (nonatomic, strong) NSArray<OSSVTransporteSpliteGoodsModel *> *goodsList;
@end

NS_ASSUME_NONNULL_END
