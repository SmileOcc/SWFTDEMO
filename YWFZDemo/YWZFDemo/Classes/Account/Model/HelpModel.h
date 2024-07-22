//
//  HelpModel.h
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@interface HelpModel : NSObject<YYModel>
@property (nonatomic, copy) NSString * helpId;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * url;

@end
