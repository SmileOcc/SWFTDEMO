//
//  ZFLiveVideoCommentListView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFVideoLiveConfigureInfoUtils.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFLiveVideoCommentListView : UIView

@property (nonatomic, copy) void (^closeBlock)(void);

- (void)zfViewWillAppear;

- (void)showCommentListView:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
