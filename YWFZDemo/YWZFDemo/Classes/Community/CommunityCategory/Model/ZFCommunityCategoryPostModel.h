//
//  ZFCategoryWaterfallModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityCategoryPostChannelModel.h"
#import <YYModel/YYModel.h>

@interface ZFCommunityCategoryPostModel : NSObject <YYModel>

@property (nonatomic, copy) NSString                                *cat_id;
@property (nonatomic, copy) NSString                                *add_time;
@property (nonatomic, copy) NSString                                *cat_name;
@property (nonatomic, copy) NSString                                *cat_description;
@property (nonatomic, copy) NSString                                *level;
@property (nonatomic, copy) NSString                                *parent_id;
@property (nonatomic, copy) NSString                                *pic_url;
@property (nonatomic, copy) NSString                                *platform;
@property (nonatomic, copy) NSString                                *selectable;
@property (nonatomic, copy) NSString                                *site_cate_id;
@property (nonatomic, copy) NSString                                *sort;
@property (nonatomic, copy) NSString                                *status;
@property (nonatomic, copy) NSString                                *theme;
@property (nonatomic, copy) NSString                                *title;
@property (nonatomic, copy) NSString                                *type;
@property (nonatomic, copy) NSString                                *url;

@property (nonatomic, strong) NSArray<ZFCommunityCategoryPostChannelModel *> *sonList;

@end
