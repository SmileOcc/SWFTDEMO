//
//  ZFCMSVideoPlayerManager.h
//  ZZZZZ
//
//  Created by YW on 2019/9/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFLiveBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    ZFVideoPlayerType_OnlyOne,
    ZFVideoPlayerType_Multiple
}ZFVideoPlayerType;


@interface ZFCMSVideoPlayerManager : NSObject

@property (nonatomic, assign) ZFVideoPlayerType playerType;

@property (nonatomic, strong, readonly) ZFLiveBaseView *currentPlayer;

+ (instancetype)manager:(ZFVideoPlayerType)type superView:(UIView *)superView;

- (void)startPlayer:(NSString *)videoId frame:(CGRect)frame;

- (void)stopCurrentPlayer;

- (void)videoPlayerScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)videoPlayerScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)videoPlayerScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
