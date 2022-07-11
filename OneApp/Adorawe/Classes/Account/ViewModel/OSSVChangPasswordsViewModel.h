//
//  OSSVChangPasswordsViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

UIKIT_EXTERN NSString *const ChangePasswordKeyOfOldWord;
UIKIT_EXTERN NSString *const ChangePasswordKeyOfNewWord;

@interface OSSVChangPasswordsViewModel : BaseViewModel

@property (nonatomic, weak) UIViewController *controller;

@end
