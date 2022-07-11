//
//  YXFloatingAudioView.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMDragView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXFloatingAudioView : WMDragView

+ (YXFloatingAudioView *)sharedView;

- (void)startH5Play:(NSDictionary *)paramsJson;

- (void)hideFloating;

@end

NS_ASSUME_NONNULL_END
