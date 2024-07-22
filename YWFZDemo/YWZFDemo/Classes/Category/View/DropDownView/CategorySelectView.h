//
//  CategorySelectView.h
//  ListPageViewController
//
//  Created by YW on 8/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDataManager.h"

// 新版分类
typedef NS_ENUM(NSInteger,SelectViewDataType) {
    SelectViewDataTypeUnKnow = -1,
    SelectViewDataTypeCategory = 0,
    SelectViewDataTypeSort,
    SelectViewDataTypeRefine,
    SelectViewDataTypeWord
};

typedef void(^SelectCompletionHandler)(NSInteger tag, SelectViewDataType type);

typedef void(^SelectSubCellHandler)(CategoryNewModel *model, SelectViewDataType type);

typedef void(^MaskTapCompletionHandler)(NSInteger index);

typedef void(^SelectAnimationStopCompletionHandler)(void);

@interface CategorySelectView : UIView

@property (nonatomic, assign) BOOL isVirtual;

@property (nonatomic, strong) NSArray<NSString *>   *sortArray;

@property (nonatomic, strong) NSArray   *categoryArray;

@property (nonatomic, copy) NSString   *currentSortType;

@property (nonatomic, copy) NSString   *currentCategory;

@property (nonatomic, copy) NSString   *currentCateId;

@property (nonatomic, copy) NSString   *currentPriceType;

@property (nonatomic, assign) BOOL   isPriceList;

@property (nonatomic, assign) SelectViewDataType   dataType;

@property (nonatomic, copy) SelectCompletionHandler   selectCompletionHandler;

@property (nonatomic, copy) SelectSubCellHandler      selectSubCellHandler;

@property (nonatomic, copy) MaskTapCompletionHandler  maskTapCompletionHandler;

@property (nonatomic, copy) SelectAnimationStopCompletionHandler selectAnimationStopCompletionHandler;

- (void)showCompletion:(void (^)(void))completion;

- (void)dismiss;
@end
