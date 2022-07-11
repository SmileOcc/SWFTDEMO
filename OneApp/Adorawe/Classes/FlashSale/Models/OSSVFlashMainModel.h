//
//  OSSVFlashMainModel.h
// XStarlinkProject
//
//  Created by odd on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVFlashChannelModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashMainModel : NSObject
@property (nonatomic, strong) NSArray<OSSVFlashChannelModel*> *activeTabs;
@property (nonatomic, strong) OSSVAdvsEventsModel *bannerInfo;

@end

NS_ASSUME_NONNULL_END
