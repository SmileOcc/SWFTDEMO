//
//  ZFAddressTests.m
//  ZZZZZTests
//
//  Created by YW on 2019/5/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Header.h"
#import "ZFAddressLibraryManager.h"
#import "ZFAddressModifyViewModel.h"
#import "ZFAddressViewModel.h"

@interface ZFAddressTests : XCTestCase

@property (nonatomic, strong) ZFAddressModifyViewModel          *viewModel;
@property (nonatomic, strong) ZFAddressViewModel                *addressViewModel;

@end

@implementation ZFAddressTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.addressViewModel = nil;
    self.viewModel = nil;
}


///地址列表
- (void)testAddressListData {
    kTests_Current_time(startTime)
    NSString *source = @"0"; //0 个人中心，1 购物车
    [self.addressViewModel requestAddressListNetwork:@{@"source":source} completion:^(id obj) {
        kTests_Result(@"ZFAddressTests_success_地址列表",obj,startTime);
        NOTIFY // 继续执行
        
    } failure:^(id obj) {
        kTests_Result(@"ZFAddressTests_failure_地址列表",obj,startTime);
        NOTIFY // 继续执行
    }];
    WAIT  //暂停
}

///当前默认选中地址信息
- (void)testAddressCurrentCountry {
    kTests_Current_time(startTime)
    [self.viewModel requestCountryName:^(NSDictionary *countryInfoDic) {
        if (countryInfoDic) {
            kTests_Result(@"ZFAddressTests_success_地址库",countryInfoDic,startTime);
        } else {
            kTests_Result(@"ZFAddressTests_failure_地址库",countryInfoDic,startTime);
        }
        NOTIFY
    }];
    WAIT
}

///实时查询地址库
- (void)testAddressLibrary {
    kTests_Current_time(startTime)
    [ZFAddressLibraryManager requestAreaLinkAge:@{
                                                  @"country_name" :   @"Vietnam",
                                                  @"state"        :   @"Bà Rịa - Vũng Tàu",
                                                  @"city"         :   @"Huyện Long Thành",
                                                  @"town"         :   @"",
                                                  @"is_child"     :   @"0",
                                                  @"ignore"       :   @"0",
                                                  } completion:^(ZFAddressCountryResultModel *resultModel) {
                                                      kTests_Result(@"ZFAddressTests_success_地址库",resultModel,startTime);
                                                      NOTIFY // 继续执行
                                                  } failure:^(id obj) {
                                                      // 传统测试代码耗时方法
                                                      kTests_Result(@"ZFAddressTests_failure_地址库",obj,startTime);
                                                      NOTIFY // 继续执行
                                                  }];
    
    WAIT  //暂停
}

///内部经纬度定位
- (void)testAddressLocation {
    NSDictionary *parmaters = @{@"latitude"  : @"22.507919",
                                @"longitude"  : @"113.9171921"};
    kTests_Current_time(startTime)
    [self.viewModel requestLocationAddress:parmaters completion:^(id obj) {
        kTests_Result(@"ZFAddressTests_success_地址经纬度定位",obj,startTime);
        NOTIFY // 继续执行
    } failure:^(id obj) {
        kTests_Result(@"ZFAddressTests_failure_地址经纬度定位",obj,startTime);
        NOTIFY // 继续执行
    }];
    WAIT  //暂停
}


- (ZFAddressModifyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFAddressModifyViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFAddressViewModel *)addressViewModel {
    if (!_addressViewModel) {
        _addressViewModel = [[ZFAddressViewModel alloc] init];
    }
    return _addressViewModel;
}
@end
