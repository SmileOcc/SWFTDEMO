//
//  YXOptionalMenuView.h
//  uSmartOversea
//
//  Created by ellison on 2018/10/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSecuID.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, YXMenuItemType) {
    YXMenuItemTypeStick   =  1 << 0,
    YXMenuItemTypeDelete  =  1 << 1,
    YXMenuItemTypeManage  =  1 << 2,
    YXMenuItemTypeEdit    =  1 << 3,
};

@protocol YXOptionalMenuViewDelegate <NSObject>

@optional
- (void)menuClickStick:(id<YXSecuIDProtocol>)secu with:(NSString *)name;
- (void)menuClickDelete:(id<YXSecuIDProtocol>)secu;
- (void)menuClickManage:(id<YXSecuIDProtocol>)secu with:(NSString *)name;
- (void)menuClickEdit:(id<YXSecuIDProtocol>)secu;

@end

@interface YXOptionalMenuView : UIView

@property (nonatomic, assign) YXMenuItemType itemType;
@property (nonatomic, weak) id<YXOptionalMenuViewDelegate> delegate;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) id<YXSecuIDProtocol> selectedSecu;

- (void)setTargetPoint:(CGPoint)point rect:(CGRect)targetRect;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
