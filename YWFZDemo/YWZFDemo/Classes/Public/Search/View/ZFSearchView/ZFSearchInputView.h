//
//  ZFSearchInputView.h
//  ZZZZZ
//
//  Created by YW on 2017/12/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchInputCancelCompletionHandler)(void);

typedef void(^SearchInputSearchKeyCompletionHandler)(NSString *searchKey);

typedef void(^SearchInputReturnCompletionHandler)(NSString *searchKey);

@interface ZFSearchInputView : UIView
@property (nonatomic, copy) SearchInputCancelCompletionHandler          searchInputCancelCompletionHandler;
@property (nonatomic, copy) SearchInputSearchKeyCompletionHandler       searchInputSearchKeyCompletionHandler;
@property (nonatomic, copy) SearchInputReturnCompletionHandler          searchInputReturnCompletionHandler;

@property (nonatomic, copy) NSString            *inputPlaceHolder;

- (void)clearSearchInfoOption;
@end
