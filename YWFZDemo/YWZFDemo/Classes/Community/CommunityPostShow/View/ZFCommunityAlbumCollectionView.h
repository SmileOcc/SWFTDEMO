//
//  ZFCommunityAlbumCollectionView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityAlbumCollectionView : UICollectionView<UIGestureRecognizerDelegate>


@property (nonatomic, copy) void (^touchesBeganPointBlock)(CGPoint toWindowPoint);

@property (nonatomic, assign) CGPoint startToWindowPoint;
@property (nonatomic, assign) CGPoint moveToWindowPoint;
@property (nonatomic, assign) CGFloat startOffsetY;
@property (nonatomic, assign) CGFloat moveDistance;

@property (nonatomic, assign) BOOL isDraging;



@end

NS_ASSUME_NONNULL_END
