//
//  STLHomeNavigationBar.h
// XStarlinkProject
//
//  Created by odd on 2020/7/30.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <YYImage/YYImage.h>

typedef enum : NSUInteger {
    HomeNavBarLeftSearchAction = 1,         //左侧搜索按钮
    HomeNavBarRightCarAction,            //右侧购物车按钮
    HomeNavBarRighMessageAction,
    HomeNavBarLeftCollectAction,
    
} HomeNavBarActionType;

@protocol HomeNavigationBarDelegate;
@interface OSSVHomeNavBar : YYAnimatedImageView

@property (nonatomic, weak) id <HomeNavigationBarDelegate> delegate;
@property (nonatomic, copy) void(^navBarActionBlock)(HomeNavBarActionType actionType);
//@property (nonatomic, strong) YYAnimatedImageView     *logoImageView;
@property (nonatomic, strong) UIView                  *searchBgView;
//@property (nonatomic, strong) UIButton                *leftSearchButton;
@property (nonatomic, strong) UIImageView             *searchIconView;
//@property (nonatomic, strong) UILabel                 *searchLabel;
@property (nonatomic, strong) UITextField             *inputField;
@property (nonatomic, copy)   NSArray                 *hotWordsArray;
- (void)stl_showBottomLine:(BOOL)show;

- (void)stl_setBarBackgroundImage:(UIImage *)image;

- (void)stl_setLogoImage:(YYImage *)logoImage;

- (void)showCartOrMessageCount;
@end

@protocol HomeNavigationBarDelegate <NSObject>

@optional
- (void)jumpToSearchWithKey:(NSString *)searchKey;

@end
