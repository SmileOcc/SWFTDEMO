//
//  OSSVHomeChannelsModel.h
// OSSVHomeChannelsModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

 // Type字段  1:首页Discovery  2:商品列表  3:html5 url
typedef NS_ENUM(NSUInteger, HomeItemType) {
    HomeItemDiscoveryType = 1,
    HomeItemGoodListType = 2,
    HomeItmeURLType = 3,
};

@interface OSSVHomeChannelsModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *channelId; // 频道ID 目前作为区分不同商品列表的类型
@property (nonatomic, copy) NSString *channelCode; // 频道Code 暂时还没用上
@property (nonatomic, copy) NSString *channelName;  // 频道名字 头部TabBar显示用
@property (nonatomic, copy) NSString *channelContent; // 频道内容 目前此处可作为H5 的URL 传递
@property (nonatomic, copy) NSString *en_name;
@property (nonatomic, assign) HomeItemType channelType; // 频道类型（三种）

@end
