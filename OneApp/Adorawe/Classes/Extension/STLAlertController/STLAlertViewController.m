//
//  STLViewController.m
// XStarlinkProject
//
//  Created by odd on 2020/7/2.
//  Copyright © 2020 XStarlinkProject. All rights reserved.
//

#import "STLAlertViewController.h"

@interface STLAlertViewController ()

@end

@implementation STLAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
