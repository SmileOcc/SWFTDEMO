//
//  ZFAccountTableMenuView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectMenuViewHeight (44.0 )

@interface ZFAccountTableMenuView : UICollectionReusableView

@property (nonatomic, strong) NSArray<NSString *> *datasArray;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, assign) BOOL          isHiddenUnderLineView;
///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

@end

