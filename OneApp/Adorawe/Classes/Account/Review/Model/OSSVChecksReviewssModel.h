//
//  OSSVChecksReviewssModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVChecksReviewssModel : NSObject

@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) CGFloat rateCount;
@property (nonatomic, assign) NSInteger addTime;
@property (nonatomic, strong) NSArray *reviewPic;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickname;

@end
