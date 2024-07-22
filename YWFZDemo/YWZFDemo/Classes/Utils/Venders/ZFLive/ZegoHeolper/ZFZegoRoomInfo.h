//
//  ZFZegoRoomInfo.h
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoRoomInfo : NSObject

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *anchorID;
@property (nonatomic, copy) NSString *anchorName;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, strong) NSMutableArray *streamInfo;   // stream_id 列表
@end

NS_ASSUME_NONNULL_END
