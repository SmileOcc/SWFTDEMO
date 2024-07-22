//
//  ZFOrderRefundModel.h
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFOrderRefundModel : NSObject
@property (nonatomic, assign) BOOL              status;         //是否申请成功(0 不成功 1成功)
@property (nonatomic, copy)   NSString          *msg;           //提示语

@property (nonatomic, copy) NSString *tk_page_url;
@end
