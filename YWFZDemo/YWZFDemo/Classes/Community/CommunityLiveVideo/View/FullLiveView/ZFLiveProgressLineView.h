//
//  ZFLiveProgressLineView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFLiveProgressLineView : UIView

@property (nonatomic, strong) UIView *lightLineView;
@property (nonatomic, strong) UIView *grayLineView;

@property (nonatomic, assign) CGFloat progress;


@end

NS_ASSUME_NONNULL_END
