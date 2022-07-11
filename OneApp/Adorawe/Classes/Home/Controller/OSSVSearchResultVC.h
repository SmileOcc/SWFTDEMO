//
//  OSSVSearchResultVC.h
// OSSVSearchResultVC
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVSearchResultNavBar.h"

typedef void (^SearchHistoryRefreshBlock)();
typedef void (^PopCompleteBlock)();
typedef void (^PopCompleteWithTextBlock)(NSString *searchKey);

@interface OSSVSearchResultVC : STLBaseCtrl
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *deepLinkId;
@property (nonatomic, assign) BOOL isFromSearchVC;
@property (nonatomic, copy) SearchHistoryRefreshBlock searchHistoryRefreshBlock;
@property (nonatomic, copy) PopCompleteBlock popCompleteBlock;
@property (nonatomic, copy) PopCompleteWithTextBlock popCompleteWithTextBlock;

@property (nonatomic, strong) OSSVSearchResultNavBar *searchNavbar;

@property (nonatomic, copy) NSString    *keyWordType;

@property (nonatomic, copy) NSString    *sourceDeeplinkUrl;

@end
