//
//  ZFCommunityHomeChannelBaseView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityGestureCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityHomeChannelBaseView : UIView

@property (nonatomic, strong) ZFCommunityGestureCollectionView                                *baseCollectionView;

@property (nonatomic, assign) CGFloat                                 lastOffSetY;

@property (nonatomic, strong) NSMutableArray *colorSet;

@end


NS_ASSUME_NONNULL_END
