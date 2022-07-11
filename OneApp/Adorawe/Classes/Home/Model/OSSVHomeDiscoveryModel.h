//
//  OSSVHomeDiscoveryModel.h
// OSSVHomeDiscoveryModel
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVSecondsKillsModel.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVDiscoverBlocksModel.h"
@interface OSSVHomeDiscoveryModel : NSObject

@property (nonatomic, strong) NSArray *bannerArray;
@property (nonatomic, strong) NSArray *topicArray;
@property (nonatomic, strong) NSArray *threeArray;

//秒杀字段
@property (nonatomic, strong) NSArray *secondArray;
//滚动视图字段
@property (nonatomic, strong) NSArray *scrollArray;

@property (nonatomic, strong) NSArray<OSSVDiscoverBlocksModel*> *blocklist;
@property (nonatomic, strong) NSArray *newuser;
@property (nonatomic, strong) NSDictionary *goodsList;
@property (nonatomic, strong) NSArray *index_venue;

//0元活动
@property (nonatomic, strong) NSArray *exchange;

@property (nonatomic, strong) NSArray *marqueeArray;
@property (nonatomic, strong) NSArray<STLHomeCThemeChannelModel*> *tabsArray;
//滑动商品列表
@property (nonatomic, strong) NSArray *slideImgArray;
//闪购数据
@property (nonatomic, strong) OSSVSecondsKillsModel *flashSale;

///1.3.8 banner 可配置背景
@property (nonatomic,strong) NSArray *slide_img_background;
@end

