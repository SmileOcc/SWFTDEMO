//
//  YYPhotoGroupView.h
//
//  Created by ibireme on 14/3/9.
//  Copyright (C) 2014 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YYWebImage.h"
#import <YYWebImage/YYWebImage.h>

/// Single picture's info.
@interface YYPhotoGroupItem : NSObject
@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@end


/// Used to show a group of images.
/// One-shot.
@interface YYPhotoBrowseView : UIView
@property (nonatomic, readonly) NSArray *groupItems; ///< Array<YYPhotoGroupItem>
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES

#warning add occ
@property (nonatomic, copy) void(^dismissCompletion)(NSInteger currentPage);// add by V1.1.8在商详使用时用到
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, assign)     CGRect tempImageSize;
@property (nonatomic, assign) BOOL showDismiss;

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
