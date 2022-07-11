//
//  YXViewModel.m
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import <YXKit/YXKit.h>


@interface YXViewModel () 


@property (nonatomic, strong, readwrite) id<YXViewModelServices> services;
@property (nonatomic, copy, readwrite) NSDictionary *params;

@property (nonatomic, strong, readwrite) RACSubject *errors;
@property (nonatomic, strong, readwrite) RACSubject *willDisappearSignal;
@property (nonatomic, strong, readwrite) RACSubject *didLoadSignal;
@property (nonatomic, strong, readwrite) RACSubject *willAppearSignal;
@property (nonatomic, strong, readwrite) RACSubject *didDisappearSignal;
@property (nonatomic, strong, readwrite) RACSubject *didAppearSignal;
@property (nonatomic, strong, readwrite) RACSubject *requestShowLoadingSignal;
@property (nonatomic, strong, readwrite) RACSubject *requestShowErrorSignal;
@end

@implementation YXViewModel

#ifdef DEBUG

- (void)dealloc{
    LOG_INFO(kModuleViewController, @"------------------------ viewModel dealloc");
}

#endif

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    YXViewModel *viewModel = [super allocWithZone:zone];
    
    @weakify(viewModel)
    [[viewModel
      rac_signalForSelector:@selector(initWithServices:params:)]
     subscribeNext:^(id x) {
         @strongify(viewModel)
         [viewModel initialize];
     }];
    
    return viewModel;
}

- (instancetype)initWithServices:(id<YXViewModelServices> _Nonnull)services params:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.shouldFetchLocalDataOnViewModelInitialize = YES;
        self.shouldRequestRemoteDataOnViewDidLoad = YES;
        self.title    = params[@"title"];
        self.services = services;
        self.params   = params;
    }
    return self;
}

- (RACSubject *)errors {
    if (!_errors) _errors = [RACSubject subject];
    return _errors;
}

- (RACSubject *)willDisappearSignal {
    if (!_willDisappearSignal) _willDisappearSignal = [RACSubject subject];
    return _willDisappearSignal;
}

- (RACSubject *)didLoadSignal {
    if (!_didLoadSignal) _didLoadSignal = [RACSubject subject];
    return _didLoadSignal;
}

- (RACSubject *)willAppearSignal{
    if (!_willAppearSignal) _willAppearSignal = [RACSubject subject];
    return _willAppearSignal;
}

- (RACSubject *)didAppearSignal {
    if (!_didAppearSignal) _didAppearSignal = [RACSubject subject];
    return _didAppearSignal;
}

- (RACSubject *)didDisappearSignal {
    if (!_didDisappearSignal) _didDisappearSignal = [RACSubject subject];
    return _didDisappearSignal;
}

#pragma mark - 用于网络请求时的，显示加载中和显示相关错误提示
- (RACSubject *)requestShowLoadingSignal {
    if (!_requestShowLoadingSignal) _requestShowLoadingSignal = [RACSubject subject];
    return _requestShowLoadingSignal;
}

- (RACSubject *)requestShowErrorSignal {
    if (!_requestShowErrorSignal) _requestShowErrorSignal = [RACSubject subject];
    return _requestShowErrorSignal;
}

+ (NSString * _Nonnull )loadingViewPositionKey {
    return @"loadingViewPositionKey";
}

+ (NSString * _Nonnull )loadingMessageKey {
    return @"loadingMessageKey";
}

+ (NSErrorDomain _Nonnull)defaultErrorDomain {
    return @"www.yxzq.com";
}

- (void)initialize {}
@end


