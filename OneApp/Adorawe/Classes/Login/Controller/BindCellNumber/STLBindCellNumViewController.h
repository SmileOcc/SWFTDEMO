//
//  STLBindCellNumViewController.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BindCloseBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface STLBindCellNumViewController : STLBaseCtrl
@property (copy,nonatomic) BindCloseBlock closeBlock;
@property (copy,nonatomic) void(^tapConfimBlock)(void);
@property (copy,nonatomic) void(^tapSkipBlock)(void);

@property (copy,nonatomic) NSString *couponContent;
@end

NS_ASSUME_NONNULL_END
