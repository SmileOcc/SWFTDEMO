//
//  ZFVideoLiveConfigureInfoUtils.m
//  ZZZZZ
//
//  Created by YW on 2020/1/6.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveConfigureInfoUtils.h"

@implementation ZFVideoLiveConfigureInfoUtils

+ (CGFloat)liveShowViewHeight {
    if (IPHONE_X_5_15) {
        return 144 * 3 + 44 + 50;
    }
    return 144 * 3 + 44;
}
@end
