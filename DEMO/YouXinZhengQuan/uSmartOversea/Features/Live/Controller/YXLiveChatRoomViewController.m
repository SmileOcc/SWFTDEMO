//
//  YXLiveChatRoomViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveChatRoomViewController.h"
#import "uSmartOversea-Swift.h"
#import "YXLiveChatRoomViewModel.h"
#import <Masonry/Masonry.h>

@interface YXLiveChatRoomViewController ()

@property (nonatomic, strong) YXLiveChatRoomViewModel *viewModel;

@end

@implementation YXLiveChatRoomViewController
@dynamic viewModel;

- (void)bindViewModel {
    [super bindViewModel];
    
    @weakify(self)
    [RACObserve(self.viewModel, liveModel) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x != nil) {
            self.chatRoomView.liveModel = x;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.chatRoomView];
    [self.chatRoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.chatRoomView resumeTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.chatRoomView hideStockPopupView:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
        
    [self.chatRoomView pauseTimer];
}

- (YXLiveChatRoomView *)chatRoomView {
    if (_chatRoomView == nil) {
        _chatRoomView = [[YXLiveChatRoomView alloc] init];
        _chatRoomView.watchLiveViewController = self.parentViewController;
    }
    return _chatRoomView;
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
