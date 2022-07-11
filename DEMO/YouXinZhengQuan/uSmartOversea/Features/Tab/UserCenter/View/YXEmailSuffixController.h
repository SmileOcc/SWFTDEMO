//
//  YXEmailSuffixController.h
//  uSmartOversea
//
//  Created by JC_Mac on 2019/1/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void (^VoidBlock_id)(id _Nullable );

NS_ASSUME_NONNULL_BEGIN

@interface YXEmailSuffixController : UITableViewController

@property (nonatomic, copy) VoidBlock_id block;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSArray *matchedSuffixArray;

@end

NS_ASSUME_NONNULL_END
