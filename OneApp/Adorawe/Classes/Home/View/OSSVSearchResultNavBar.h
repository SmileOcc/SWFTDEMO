//
//  STLSearchResultNavigationBar.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/5/14.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^SearchInputCancelCompletionHandler)(void);

typedef void(^SearchInputSearchKeyCompletionHandler)(NSString *searchKey);

typedef void(^SearchInputReturnCompletionHandler)(NSString *searchKey);

typedef void(^TapSerachBgViewCompletionHandler)(NSString *searchKey);  //点击搜索框背景的block


@class SearchContentView;

@interface OSSVSearchResultNavBar : UIView

@property (nonatomic, copy) SearchInputCancelCompletionHandler          searchInputCancelCompletionHandler;
@property (nonatomic, copy) SearchInputSearchKeyCompletionHandler       searchInputSearchKeyCompletionHandler;
@property (nonatomic, copy) SearchInputReturnCompletionHandler          searchInputReturnCompletionHandler;
@property (nonatomic, copy) TapSerachBgViewCompletionHandler            tapSerachBgViewCompletionHandler;

@property (nonatomic, copy)   NSString            *inputPlaceHolder;
@property (nonatomic, copy)   NSString            *searchKey;
@property (nonatomic, strong) UITextField         *searchField;
@property (nonatomic, strong) SearchContentView   *searchContenView;

- (void)clearSearchInfoOption;

- (void)becomeEditFirst;

- (void)showCartCount;

@end

@interface SearchContentView : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel     *contentLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy)   NSString    *contentString;

@end
