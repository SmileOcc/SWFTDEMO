//
//  STLShareEarnModel.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLShareEarnModel : NSObject
@property (nonatomic, strong) NSDictionary *flow_pic;
@property (nonatomic, strong) NSDictionary *url;
@property (nonatomic, strong) NSArray *flow_notice_detail;
@property (nonatomic, strong) NSDictionary *share;

@end

NS_ASSUME_NONNULL_END
