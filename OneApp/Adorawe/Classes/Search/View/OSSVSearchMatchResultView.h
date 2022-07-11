//
//  OSSVSearchMatchResultView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/28.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSearchAssociateModel.h"

typedef void(^SearchMatchResultSelectCompletionHandler)(STLSearchAssociateCatModel *category,STLSearchAssociateGoodsModel *match);

typedef void(^SearchMatchCloseKeyboardCompletionHandler)(void);

typedef void(^SearchMatchHideMatchViewCompletionHandler)(void);

@interface OSSVSearchMatchResultView : UIView

@property (nonatomic, copy) NSString            *searchKey;

@property (nonatomic, strong) NSArray<STLSearchAssociateGoodsModel *>        *matchResult;

@property (nonatomic, strong) NSArray<STLSearchAssociateCatModel*>           *recommendArray;

@property (nonatomic, copy) SearchMatchResultSelectCompletionHandler        searchMatchResultSelectCompletionHandler;

@property (nonatomic, copy) SearchMatchCloseKeyboardCompletionHandler       searchMatchCloseKeyboardCompletionHandler;

@property (nonatomic, copy) SearchMatchHideMatchViewCompletionHandler       searchMatchHideMatchViewCompletionHandler;

@end
