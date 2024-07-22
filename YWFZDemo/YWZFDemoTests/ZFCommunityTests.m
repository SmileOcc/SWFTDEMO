//
//  ZFCommunityTests.m
//  ZZZZZTests
//
//  Created by YW on 2019/5/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Header.h"

#import "ZFCommunityShowsListViewModel.h"
#import "ZFCommunityAccountViewModel.h"

@interface ZFCommunityTests : XCTestCase

@property (nonatomic, strong) ZFCommunityShowsListViewModel           *showsViewModel;
@property (nonatomic, strong) ZFCommunityAccountViewModel           *accountViewModel;

@end

@implementation ZFCommunityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.showsViewModel = nil;
    self.accountViewModel = nil;
}


/// 社区首页show帖子
- (void)testCommunityHomeShowPost {
    kTests_Current_time(startTime)
    [self.showsViewModel requestShowsListData:YES completion:^(NSArray<ZFCommunityFavesItemModel *> *showsListArray, NSDictionary *pageInfo) {
        if (showsListArray) {
            kTests_Result(@"ZFCommunityTests_success_社区首页Show",showsListArray,startTime);
        } else {
            kTests_Result(@"ZFCommunityTests_failure_社区首页Show",showsListArray,startTime);
        }
        NOTIFY // 继续执行
    }];
    WAIT
}

/// 社区个人中心信息
- (void)testCommunityAccount {
    kTests_Current_time(startTime)
    NSDictionary *dic = @{kRequestUserIdKey : USERID};
    [self.accountViewModel requestNetwork:dic completion:^(id obj) {
        kTests_Result(@"ZFCommunityTests_success_个人中心",obj,startTime);
        NOTIFY // 继续执行

    } failure:^(id obj) {
        kTests_Result(@"ZFCommunityTests_failure_个人中心",obj,startTime);
        NOTIFY // 继续执行
    }];
    WAIT
}

- (ZFCommunityShowsListViewModel *)showsViewModel{
    if (!_showsViewModel) {
        _showsViewModel = [[ZFCommunityShowsListViewModel alloc] init];
    }
    return _showsViewModel;
}

- (ZFCommunityAccountViewModel *)accountViewModel {
    if (!_accountViewModel) {
        _accountViewModel = [[ZFCommunityAccountViewModel alloc] init];
    }
    return _accountViewModel;
}
@end
