//
//  STLSearchNavigationBar.h
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchInputCancelCompletionHandler)(void);

typedef void(^SearchInputSearchKeyCompletionHandler)(NSString *searchKey);

typedef void(^SearchInputReturnCompletionHandler)(NSString *searchKey);

@interface OSSVSearchNavBar : UIView

@property (nonatomic, copy) SearchInputCancelCompletionHandler          searchInputCancelCompletionHandler;
@property (nonatomic, copy) SearchInputSearchKeyCompletionHandler       searchInputSearchKeyCompletionHandler;
@property (nonatomic, copy) SearchInputReturnCompletionHandler          searchInputReturnCompletionHandler;

@property (nonatomic, copy) NSString            *inputPlaceHolder;

@property (nonatomic, copy) NSString            *searchKey;

- (void)clearSearchInfoOption;

- (void)becomeEditFirst;

- (void)changeKeyWordForTextField:(NSString *)keyWord;

@end
