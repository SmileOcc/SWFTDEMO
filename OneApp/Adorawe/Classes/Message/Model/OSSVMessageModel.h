//
//  OSSVMessageModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVMessageModel : NSObject

@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *img_url;
//1通知 2物流 3活动 4系统
@property (nonatomic, copy) NSString *type;
//0 不显示红点物
@property (nonatomic, copy) NSString *count;

//按发送时间倒序，沙特时间
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *jump_url;
//0未开始 1 进行中 2、活动已结束
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *message_id;

@end
