//
//  ZFHomeTests.m
//  ZZZZZTests
//
//  Created by YW on 2019/5/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Header.h"
#import "ZFHomePageMenuViewModel.h"
//#import "ZFHomeCMSViewModel.h"
#import "ZFBTSDataSets.h"

@interface ZFHomeTests : XCTestCase

@property (nonatomic, strong) ZFHomePageMenuViewModel           *pageMenuViewModel;
//@property (nonatomic, strong) ZFCMSViewModel                *cmsViewModel;


@end

@implementation ZFHomeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.pageMenuViewModel = nil;
//    self.cmsViewModel = nil;
}

///首页数据
- (void)testHomeMenu {
//    kTests_Current_time(startTime)
//    [self.pageMenuViewModel requestHomePageMenuData:YES completeHandler:^(BOOL isSucceess) {
//        if (isSucceess) {
//            kTests_Result(@"ZFHomeTests_success_首页菜单",[self.pageMenuViewModel values],startTime);
//            NSString *channelId = [[self.pageMenuViewModel values] firstObject];
//            [self.cmsViewModel requestHomeListData:channelId isRequestCMSMainUrl:YES completion:^(NSArray<ZFCMSSectionModel *>*cmsModelArr, BOOL isCacheData) {
//                if (cmsModelArr) {
//                    kTests_Result(@"ZFHomeTests_success_首页list",cmsModelArr,startTime);
//                } else {
//                    kTests_Result(@"ZFHomeTests_failure_首页list",@[],startTime);
//                }
//                NOTIFY // 继续执行
//            }];
//
//        } else {
//            kTests_Result(@"ZFHomeTests_failure_首页菜单",@{},startTime);
//            NOTIFY // 继续执行
//        }
//    }];
    WAIT
//    kTests_Current_time(startTime)
//    [self.pageMenuViewModel requestHomePageMenuData:YES completeHandler:^(BOOL isSucceess) {
//        if (isSucceess) {
//            kTests_Result(@"ZFHomeTests_success_首页菜单",[self.pageMenuViewModel values],startTime);
//            NSString *channelId = [[self.pageMenuViewModel values] firstObject];
//            [self.cmsViewModel requestHomeListData:channelId completion:^(NSArray<ZFCMSSectionModel *>*cmsModelArr, BOOL isCacheData) {
//                if (cmsModelArr) {
//                    kTests_Result(@"ZFHomeTests_success_首页list",cmsModelArr,startTime);
//                } else {
//                    kTests_Result(@"ZFHomeTests_failure_首页list",@[],startTime);
//                }
//                NOTIFY // 继续执行
//            }];
//            
//        } else {
//            kTests_Result(@"ZFHomeTests_failure_首页菜单",@{},startTime);
//            NOTIFY // 继续执行
//        }
//    }];
//    WAIT
}

- (ZFHomePageMenuViewModel *)pageMenuViewModel {
    if (!_pageMenuViewModel) {
        _pageMenuViewModel = [[ZFHomePageMenuViewModel alloc] init];
    }
    return _pageMenuViewModel;
}

//- (ZFCMSViewModel *)cmsViewModel {
//    if (!_cmsViewModel) {
//        _cmsViewModel = [[ZFCMSViewModel alloc] init];
//    }
//    return _cmsViewModel;
//}
@end
