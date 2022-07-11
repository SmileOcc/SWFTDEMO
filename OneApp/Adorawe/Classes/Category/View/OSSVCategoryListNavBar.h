//
//  OSSVCategoryListNavBar.h
// XStarlinkProject
//
//  Created by Kevin on 2021/9/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchInputCancelCompletionHandler)(void);


typedef void(^TapContentbgViewCompletionHandler)(NSString *searchKey); //点击白色文本背景的block

typedef void(^TapSerachBgViewCompletionHandler)(NSString *searchKey);  //点击搜索框背景的block

typedef void(^TapBagButtonCompletionHandler)(void);

@interface OSSVCategoryListNavBar : UIView

@property (nonatomic, copy) SearchInputCancelCompletionHandler          searchInputCancelCompletionHandler;
@property (nonatomic, copy) TapContentbgViewCompletionHandler           tapContentbgViewCompletionHandler;
@property (nonatomic, copy) TapSerachBgViewCompletionHandler            tapSerachBgViewCompletionHandler;
@property (nonatomic, copy) TapBagButtonCompletionHandler               tapBagButtonCompletionHandler;

@property (nonatomic, copy) NSString *searchKey;

- (void)becomeEditFirst;

- (void)showCartCount;

@end

