//
//  ZFCommunityChannelModel.h
//  ZZZZZ
//
//  Created by YW on 2018/11/23.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFCommunityChannelItemModel;

@interface ZFCommunityChannelModel : NSObject

@property (nonatomic, strong) NSArray <ZFCommunityChannelItemModel *> *data;
@end


@interface ZFCommunityChannelItemModel : NSObject

@property (nonatomic, copy) NSString      *cat_name;
@property (nonatomic, copy) NSString      *idx;


@end
