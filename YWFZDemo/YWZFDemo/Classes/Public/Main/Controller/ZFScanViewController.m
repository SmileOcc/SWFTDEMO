//
//  ZFScanViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/5/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFScanViewController.h"
#import "OKZBarView.h"
#import "Constants.h"
#import "Masonry.h"
#import "BigClickAreaButton.h"

@interface ZFScanViewController ()

@property (nonatomic, strong) OKZBarView *scanView;

@property (nonatomic, strong) BigClickAreaButton *backButton;

@end

@implementation ZFScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self zfInitView];
    [self zfAutoLayoutView];
    
}

- (void)zfInitView {
    self.scanView = [OKZBarView openZbarView:self startScan:YES height:self.view.bounds.size.height completionBlock:^(BOOL ret, NSString *scanCodeType, NSString *result) {
        YWLog(@"%@__%@", scanCodeType, result);
    }];
    
    [self.view addSubview:self.backButton];
}

- (void)zfAutoLayoutView {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(30);
        make.leading.mas_equalTo(15);
    }];
}

- (void)goBackAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BigClickAreaButton *)backButton {
    if (!_backButton) {
        _backButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"versionGuide_close"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
