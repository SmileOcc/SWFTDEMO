//
//  ZFOutfitRefineToolBar.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClearBlock)(void);
typedef void(^ApplyBlock)(void);

@interface ZFOutfitRefineToolBar : UIView

@property (nonatomic, copy) ClearBlock       clearBlock;
@property (nonatomic, copy) ApplyBlock       applyBlock;


@end

NS_ASSUME_NONNULL_END
