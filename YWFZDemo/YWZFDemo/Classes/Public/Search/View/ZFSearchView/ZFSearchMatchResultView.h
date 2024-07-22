//
//  ZFSearchMatchResultView.h
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchMatchResultSelectCompletionHandler)(NSString *matchKey);

typedef void(^SearchMatchCloseKeyboardCompletionHandler)(void);

typedef void(^SearchMatchHideMatchViewCompletionHandler)(void);

@interface ZFSearchMatchResultView : UIView

@property (nonatomic, copy) NSString            *searchKey;

@property (nonatomic, strong) NSArray           *matchResult;

@property (nonatomic, strong) NSArray           *historyArray;

@property (nonatomic, copy) SearchMatchResultSelectCompletionHandler        searchMatchResultSelectCompletionHandler;

@property (nonatomic, copy) SearchMatchCloseKeyboardCompletionHandler       searchMatchCloseKeyboardCompletionHandler;

@property (nonatomic, copy) SearchMatchHideMatchViewCompletionHandler       searchMatchHideMatchViewCompletionHandler;
@end
