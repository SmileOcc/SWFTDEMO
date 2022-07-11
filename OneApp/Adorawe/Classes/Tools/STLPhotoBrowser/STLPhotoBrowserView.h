//
//  STLPhotoBrowserView.h
// XStarlinkProject
//
//  Created by odd on 2021/6/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLPhotoGroupItem : NSObject
@property (nonatomic, strong) UIView                *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize                largeImageSize;
@property (nonatomic, strong) NSURL                 *largeImageURL;
@end


@interface STLPhotoBrowserView : UIView

@property (nonatomic, readonly) NSArray             *groupItems; ///< Array<YYPhotoGroupItem>
@property (nonatomic, readonly) NSInteger           currentPage;
@property (nonatomic, assign) BOOL                  blurEffectBackground; ///< Default is YES

@property (nonatomic, copy) void(^dismissCompletion)(NSInteger currentPage);// add by V1.1.8在商详使用时用到
@property (nonatomic, strong) UIButton              *dismissButton;
@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic, assign) CGRect                tempImageSize;
@property (nonatomic, assign) BOOL                  showDismiss;
@property (nonatomic, assign) BOOL                  isHidePager;

@property (nonatomic, strong) UICollectionView      *bottomCollectView;
@property (nonatomic, assign) BOOL                  isDismissToFirstPosition;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithGroupItems:(NSArray *)groupItems;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end

