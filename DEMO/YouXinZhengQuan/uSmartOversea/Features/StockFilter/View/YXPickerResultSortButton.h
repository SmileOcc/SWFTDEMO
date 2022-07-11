//
//  YXPickerResultSortButton.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface YXPickerResultSortButton :  QMUIButton

@property (nonatomic, assign) YXSortState sortState;
@property (nonatomic, assign) NSInteger filterType;

+ (instancetype)buttonWithSortType:(NSInteger)filterType sortState:(YXSortState)sortState;

@end

NS_ASSUME_NONNULL_END
