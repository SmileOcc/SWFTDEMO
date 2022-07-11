//
//  OSSVAccountTablesMenuView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kSelectMenuViewHeight (44.0 )


@interface OSSVAccountTablesMenuView : UIView

@property (nonatomic, strong) NSArray<NSString *> *datasArray;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, assign) BOOL          isHiddenUnderLineView;
///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
