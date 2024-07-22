//
//  ZFOrderReviewViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/10/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderReviewViewController.h"
#import "ZFOrderCommentContentView.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"

@interface ZFOrderReviewViewController ()
<ZFInitViewProtocol>

@property (nonatomic, strong) ZFOrderCommentContentView *contentView;

@end

@implementation ZFOrderReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)zfInitView {
    self.view.backgroundColor = ZFC0xFFFFFF();
    [self.view addSubview:self.contentView];
}

- (void)zfAutoLayoutView {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}


#pragma mark - Property Method

- (ZFOrderCommentContentView *)contentView {
    if (!_contentView) {
        _contentView = [[ZFOrderCommentContentView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}
@end
