//
//  YXSortButton.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface YXSortButton : QMUIButton

@property (nonatomic, assign) YXSortState sortState;
@property (nonatomic, assign) YXMobileBrief1Type mobileBrief1Type;

+ (instancetype)buttonWithSortType:(YXMobileBrief1Type)mobileBrief1Type sortState:(YXSortState)sortState;

@end

NS_ASSUME_NONNULL_END
