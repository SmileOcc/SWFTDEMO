//
//  STLActivityWWebCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import <WebKit/WebKit.h>
#import "H5ShareModel.h"

typedef void(^complation)(void);

@interface STLActivityWWebCtrl : STLBaseCtrl

@property (nonatomic, copy) NSString        *strUrl;

@property (nonatomic,strong) H5ShareModel   *model;

@property (nonatomic, copy) complation      ActivityWKWebComplation;

@property (nonatomic, assign) BOOL          isIgnoreWebTitle;


- (void)callBackIsOpenPush:(NSString *)callBackString resultValue:(NSInteger)resultValue;

@end
