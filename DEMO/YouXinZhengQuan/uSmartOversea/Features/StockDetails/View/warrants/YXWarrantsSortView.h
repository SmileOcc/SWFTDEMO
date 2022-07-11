//
//  YXWarrantsSortView.h
//  uSmartOversea
//
//  Created by 井超 on 2019/7/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXWarrantsSortView : UIScrollView

@property (nonatomic, copy) void (^seletedBlock)(NSInteger);
- (instancetype)initWithTitleArr:(NSArray *)titleArr selectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
