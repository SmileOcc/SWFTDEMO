//
//  OSSVCategoryNavigatiBar.h
// XStarlinkProject
//
//  Created by odd on 2020/8/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <YYImage/YYImage.h>
#import "OSSVCategorySearchsView.h"

typedef enum : NSUInteger {
    CategoryNavBarLeftSearchAction = 1,
    CategoryNavBarRightCarAction,            //右侧购物车按钮
    CategorySearchAction,
} CategoryNavBarActionType;

@protocol STLCategoryNavigationBarDelegate;

@interface OSSVCategoryNavigatiBar : YYAnimatedImageView

@property (nonatomic, weak) id <STLCategoryNavigationBarDelegate> delegate;
@property (nonatomic, copy) NSString            *inputPlaceHolder;
@property (nonatomic, copy) void(^navBarActionBlock)(CategoryNavBarActionType actionType);
@property (nonatomic, strong) OSSVCategorySearchsView   *searchBarView;

- (void)stl_showBottomLine:(BOOL)show;

- (void)stl_setBarBackgroundImage:(UIImage *)image;

//- (void)stl_setLogoImage:(YYImage *)logoImage;

- (void)showCartCount;
@end

@protocol STLCategoryNavigationBarDelegate <NSObject>

@optional

- (void)jumpToSearchWithKey:(NSString *)searchKey;

@end
