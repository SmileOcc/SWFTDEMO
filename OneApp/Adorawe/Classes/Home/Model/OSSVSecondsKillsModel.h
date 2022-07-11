//
//  OSSVSecondsKillsModel.h
// OSSVSecondsKillsModel
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  秒杀模型
/**
 *  header
 *  倒计时
 *  若干个长方形商品
 **/

#import <Foundation/Foundation.h>
#import "OSSVAdvsEventsModel.h"
#import "OSSVHomeGoodsListModel.h"

@interface OSSVSecondsKillsModel : NSObject

///头部跳转的模型
@property (nonatomic, strong) OSSVAdvsEventsModel  *banner;
///倒计时时间格式是剩余多少秒
@property (nonatomic, copy) NSString            *timing;
//底部商品列表HomeGoodListModel
@property (nonatomic, strong) NSArray           *goods_list;
///结束跳转类型
@property (nonatomic, strong) OSSVAdvsEventsModel  *end_more;
//倒计时截止 title
@property (nonatomic, copy) NSString *endStr;

//离活动结束还剩余的秒数
@property (nonatomic, assign)  double timeCount;
//闪购商品
@property (nonatomic, strong) NSArray<OSSVHomeGoodsListModel *> *goodsList;
@end
