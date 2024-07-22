//
//  ZFCOPVIPViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/3/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCODVIPViewController.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "SystemConfigUtils.h"
#import <Masonry/Masonry.h>

@interface ZFCODVIPViewController ()

@end

@implementation ZFCODVIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)goBackAction
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        if (self.didDismissHandle) {
            self.didDismissHandle();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
