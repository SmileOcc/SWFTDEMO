//
//  OSSVTabBarVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVTabBarVC : UITabBarController

- (OSSVNavigationVC *)navigationControllerWithMoudle:(STLMainMoudle)moudle;
- (void)setModel:(STLMainMoudle)model;

@end
