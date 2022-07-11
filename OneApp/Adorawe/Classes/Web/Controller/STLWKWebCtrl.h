//
//  STLWKWebCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@interface STLWKWebCtrl : STLBaseCtrl
@property (nonatomic,assign) SystemURLType urlType;
@property (nonatomic,assign) BOOL isPresentVC;
@property (nonatomic,assign) BOOL isNoNeedsWebTitile;

@property (nonatomic,copy) NSString *url;
@property (nonatomic,assign) BOOL showClose;
@end
