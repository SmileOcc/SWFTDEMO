//
//  YXStockPickerResultViewModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXSecuMobileBrief1Protocol.h"
#import "YXSecuProtocol.h"
#import "YXSecuGroup.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXStockPickerList;
@class YXStokFilterGroup;

@interface YXStockPickerResultViewModel : YXTableViewModel

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) RACCommand *didClickRotateCommand;
@property (nonatomic, strong) RACCommand *didClickSortCommand;
@property (nonatomic, strong) RACCommand *saveResultCommand;
@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) RACSubject *requestSubject;
@property (nonatomic, strong) RACSubject *saveSubject;
@property (nonatomic, strong) RACSubject *endRefreshSubject;
@property (nonatomic, strong) RACSubject *bmpSubject;
@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, assign) YXSortState sortState;
@property (nonatomic, assign) NSInteger filterType;

@property (nonatomic, copy) NSArray<YXStockPickerList *> *checkedSecus;
@property (nonatomic, strong) YXSecuGroup *secuGroup;

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSInteger updateType; //0-新增， 1-修改
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSArray<YXStokFilterGroup *> *groups;
@property (nonatomic, strong) NSArray<NSNumber *> *sortTypes;

@property (nonatomic, strong) NSDictionary *namesDictionary;

@property (nonatomic, assign) int userLevel;

- (BOOL)isChecked:(YXStockPickerList *)secu;
- (void)check:(YXStockPickerList *)secu;
- (void)unCheck:(YXStockPickerList *)secu;
- (void)AllCheck;
- (void)removeAllChecked;

@end

NS_ASSUME_NONNULL_END
