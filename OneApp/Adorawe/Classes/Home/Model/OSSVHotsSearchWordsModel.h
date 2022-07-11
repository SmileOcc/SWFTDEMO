//
//  OSSVHotsSearchWordsModel.h
// OSSVHotsSearchWordsModel
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVHotsSearchWordsModel : NSObject

/**
 {
 "add_time" = 1482718948;
 "app_type" = ios;
 display = 1;
 "group_id" = index;
 id = 1;
 "page_type" = 2;
 position = search;
 sort = 1;
 "up_time" = 1482718948;
 url = "Adorawe://action?actiontype=2&url=480&name=Dresses&source=deeplink";
 word = "long dress";
 }
 */
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, copy) NSString *app_type;
@property (nonatomic, copy) NSString *display;
@property (nonatomic, copy) NSString *group_id;
@property (nonatomic, copy) NSString *iD;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *up_time;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSString *trendsId;
@property (nonatomic, assign) NSInteger is_hot;//是否是热搜词 0为否 1为是

@end
