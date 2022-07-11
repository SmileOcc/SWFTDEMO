//
//  OSSVSearchVC.h
// OSSVSearchVC
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVSearchNavBar.h"

@interface OSSVSearchVC : STLBaseCtrl

@property (nonatomic, copy) NSString                 *enterName;
@property (nonatomic, copy) NSString                 *catId;
@property (nonatomic, strong) OSSVSearchNavBar *searchNavbar;
@property (nonatomic, copy) NSString                 *searchTitle; //传入的搜索标题

@end
