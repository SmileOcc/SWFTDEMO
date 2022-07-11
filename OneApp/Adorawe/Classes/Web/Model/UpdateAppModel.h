//
//  UpdateAppModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateAppModel : NSObject

@property (nonatomic, assign) BOOL isUpdate;    // 是否引导更新
@property (nonatomic, copy) NSString *title;    // 更新标题
@property (nonatomic, copy) NSString *updateMsg;// 更新说明
@property (nonatomic, copy) NSString *url;      // 更新跳转链接

@end
