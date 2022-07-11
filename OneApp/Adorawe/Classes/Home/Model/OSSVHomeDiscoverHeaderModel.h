//
//  OSSVHomeDiscoverHeaderModel.h
// OSSVHomeDiscoverHeaderModel
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVAdvsEventsModel;

@interface OSSVHomeDiscoverHeaderModel : NSObject //<NSCopying>
/**
 *  此处Model，作为一个过渡使用的传值使用；没有直接接收后台数据的
 */
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *bannerArray;
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *topicArray;
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *threeArray;
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *listArray;

@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *> *oneBannerArray;
@property (nonatomic, strong) NSArray *blocklist;
@property (nonatomic, strong) NSArray *goodslist;
@property (nonatomic, strong) NSArray *newuser;

/**
 *  此时我有一个这样的需求，假如后台返回
 */


@end
