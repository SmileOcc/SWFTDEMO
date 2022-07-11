//
//  STLBaseCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "WMPageController.h"

@interface STLBaseCtrl()

@property (nonatomic, assign) BOOL isFirstAppear;
@end

@implementation STLBaseCtrl

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [OSSVAnalyticPagesManager sharedManager].currentPageName = NSStringFromClass(self.class);

    if (self.isModalPresent) {
        WINDOW.backgroundColor = [OSSVThemesColors stlBlackColor];
    }
    

    //此方法是为了防止控制器的title发生偏移，造成这样的原因是因为返回按钮的文字描述占位
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    if ([viewControllerArray containsObject:self])
    {
        long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
        UIViewController *previous;
        if (previousViewControllerIndex >= 0){
            previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
            previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
        }
    } else {//特殊处理
        UIViewController *lastCtrl = viewControllerArray.lastObject;
        if ([lastCtrl isKindOfClass:[WMPageController class]]) {
            long previousViewControllerIndex = [viewControllerArray indexOfObject:lastCtrl] - 1;
            UIViewController *previous;
            if (previousViewControllerIndex >= 0) {
                previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
                previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.isModalPresent) {
        WINDOW.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [OSSVAnalyticPagesManager sharedManager].currentPageName = NSStringFromClass(self.class);
    [OSSVAnalyticPagesManager sharedManager].lastPageCode = [OSSVAnalyticPagesManager sharedManager].currentPageCode;
    [OSSVAnalyticPagesManager sharedManager].currentPageCode = self.currentPageCode;
    

    if (!self.isModalPresent) {
        WINDOW.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    
    if (!self.isFirstAppear) {
        self.isFirstAppear = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{        
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventScreenView
                                        parameters:@{
                                            kFIRParameterScreenClass: NSStringFromClass(self.class),
                                            kFIRParameterScreenName: STLToString(self.title)
                                        }];
        });
    }
}

- (void)setIsModalPresent:(BOOL)isModalPresent {
    _isModalPresent = isModalPresent;
    if (isModalPresent) {
        WINDOW.backgroundColor = [OSSVThemesColors stlBlackColor];
    } else {
        WINDOW.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
}

//电池栏颜色 UIStatusBarStyleLightContent 白色 UIStatusBarStyleDefault 黑色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)stlInitView {
    
}

- (void)stlAutoLayoutView {
    
}
-(NSMutableArray <OSSVBasesRequests *>*)operations {
    if (!_operations) {
        _operations = [[NSMutableArray alloc] init];
    }
    return _operations;
}

- (NSMutableDictionary *)transmitMutDic {
    if (!_transmitMutDic) {
        _transmitMutDic = [[NSMutableDictionary alloc] init];
    }
    return _transmitMutDic;
}

- (void)dealloc
{
    STLLog(@"%@ had dealloc",[NSString stringWithUTF8String:object_getClassName(self)]);
}

-(void)stopRequest
{
    for (int i = 0; i < [self.operations count]; i++) {
        OSSVBasesRequests *request = self.operations[i];
        [request stop];
    }
    [self.operations removeAllObjects];
}

/**
 * 导航栏左上角返回按钮事件
 */
-(void)goBackAction {
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self){
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
}
@end
