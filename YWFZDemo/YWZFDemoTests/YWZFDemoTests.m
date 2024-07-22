//
//  ZZZZZTests.m
//  ZZZZZTests
//
//  Created by YW on 2019/5/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/runtime.h>
#import "Constants.h"
#import "ZFAnalyticsInjectProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "YWLocalHostManager.h"
#import "Header.h"
#import "ZFBTSDataSets.h"
#import "ZFOrderSuccessViewController.h"

@interface ZZZZZTests : XCTestCase

@end

@implementation ZZZZZTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDataSets
{
    for (int i = 0; i < 10; i++) {
        [[ZFBTSDataSets sharedInstance] addObject:[self gainRandomBtsModel]];
    }
    NSMutableArray *testList = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        ZFBTSModel *btsModel = [[ZFBTSModel alloc] init];
        btsModel.planid = @"";
        btsModel.policy = @"";
        btsModel.bucketid = @"";
        btsModel.plancode = @"";
        btsModel.versionid = @"";
        [testList addObject:btsModel];
    }
    for (int i = 0; i < 5; i++) {
        ZFBTSModel *btsModel = [[ZFBTSModel alloc] init];
        btsModel.planid = @"";
        btsModel.policy = @"";
        btsModel.bucketid = @"";
        btsModel.plancode = @"";
        btsModel.versionid = @"";
        [[ZFBTSDataSets sharedInstance] addObject:btsModel];
    }
    [testList addObject:[self gainRandomBtsModel]];
    [[ZFBTSDataSets sharedInstance] addObjectFromeArray:testList];
    YWLog(@"%@", [[ZFBTSDataSets sharedInstance] gainBtsSets]);
    YWLog(@"[[ZFBTSDataSets sharedInstance] gainBtsSets] ------- %ld", [[ZFBTSDataSets sharedInstance] gainBtsSets].count);
}

- (ZFBTSModel *)gainRandomBtsModel
{
    ZFBTSModel *btsModel = [[ZFBTSModel alloc] init];
    btsModel.planid = [NSString stringWithFormat:@"%d", arc4random()%10];
    btsModel.policy = [NSString stringWithFormat:@"%d", arc4random()%10];
    btsModel.bucketid = [NSString stringWithFormat:@"%d", arc4random()%10];
    btsModel.plancode = [NSString stringWithFormat:@"%d", arc4random()%10];
    btsModel.versionid = [NSString stringWithFormat:@"%d", arc4random()%10];
    return btsModel;
}

- (void)testRequest
{
//    for (int i = 0; i < 1000; i++) {
//        ZFRequestModel *requestModel = [ZFRequestModel new];
//        requestModel.url = API(Port_rate);
////        requestModel.parmaters = @{
////                                   @"test" : @(i)
////                                   };
//
//        [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
//            NSDictionary *result = responseObject[ZFResultKey];
//            if (ZFJudgeNSDictionary(result)) {
//                SaveUserDefault(kLocationInfoCountryId, ZFToString(result[@"country_id"]));
//                SaveUserDefault(kLocationInfoCountryCode, ZFToString(result[@"country_code"]));
//                SaveUserDefault(kLocationInfoPipeline, ZFToString(result[@"pipeline"]));
//                [AccountManager sharedManager].br_is_show_icon = [result[@"br_is_show_icon"] boolValue];
//            };
//            YWLog(@"ZZZZZTests request ------ %d", i);
////            NOTIFY // 继续执行
//        } failure:^(NSError *error) {
//            YWLog(@"ZZZZZTests request ------ %d", i);
////            NOTIFY // 继续执行
//        }];
//    }
//    WAIT
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
//    configuration.timeoutIntervalForRequest = 30.0;
//    configuration.timeoutIntervalForResource = 30.0;
    configuration.HTTPMaximumConnectionsPerHost = 15;
    YWLog(@"configuration.HTTPMaximumConnectionsPerHost-------%ld", configuration.HTTPMaximumConnectionsPerHost);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    for (int i = 0; i < 1000; i++) {
        ZFRequestModel *model = [ZFRequestModel new];
        model.url = API(Port_initialization);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:API(Port_rate)]];
        request.HTTPBody = [model.parmaters yy_modelToJSONData];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 10;
        [request setValue:[model parmatersMd5SignHeaderValue] forHTTPHeaderField:[model parmatersMd5SignHeaderKey]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            YWLog(@"ZZZZZTests request ------ %d", i);
            if (error) {
                YWLog(@"请求失败 ------ %@", error);
            } else {
                NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                YWLog(@"请求数据 ------ %@", jsonResult);
            }
//                YWLog(@"[session.delegateQueue.operations count]  -------------%ld", [session.delegateQueue.operations count]);
        }];
        [task resume];
    }
    WAIT
}

/**
 统计代码Aop单元测试，可以排查统计Aop跟踪的方法有没有被修改
 */
- (void)testAnalyticsBeforeRelease {
    
    ///链路控制查找测试
    [self unFindBKClass];
    
    ///实现AOP统计相关方法排查提示
    [self unFindListAnalyticsAOP];
}

///链路控制查找测试
- (void)unFindBKClass {
    
    BOOL hasSuccess = YES;
    unsigned classCount = objc_getClassList(NULL, 0);
    Class *allClasses = (Class *)malloc(sizeof(Class) * (classCount + 1));
    classCount = objc_getClassList(allClasses, classCount);
    
    // 链路类名字典
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ZFBrainKeeper" ofType:@"plist"]];
    NSMutableArray *allClassStringArray = [[NSMutableArray alloc] init];
    
    //遍历所有的类
    for (unsigned classIndex = 0;classIndex < classCount;++classIndex) {
        Class class = allClasses[classIndex];
        [allClassStringArray addObject:NSStringFromClass(class)];
    }
    
    // 链路类名单元测试
    NSMutableArray *unFindBKClass = [NSMutableArray array];
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        NSArray *bkClassArray = dataDict.allKeys;
        for (NSString *bkClassString in bkClassArray) {
            if (![allClassStringArray containsObject:bkClassString]) {
                [unFindBKClass addObject:bkClassString];
            }
        }
        if ([unFindBKClass count]) {
            YWLog(@"单元测试(链路)：发现如下控制器未找到");
            [unFindBKClass enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YWLog(@"%@", obj);
            }];
            hasSuccess = NO;
        }
    }
    
    XCTAssertTrue(hasSuccess, @" ======= 单元测试(链路) =======  发现如下控制器未找到");
}

///实现AOP统计相关方法排查提示
- (void)unFindListAnalyticsAOP {
    
    BOOL hasSuccess = YES;
    unsigned classCount = objc_getClassList(NULL, 0);
    Class *allClasses = (Class *)malloc(sizeof(Class) * (classCount + 1));
    classCount = objc_getClassList(allClasses, classCount);
    
    NSMutableArray *allAopClass = [[NSMutableArray alloc] init];
    
    //遍历所有的类
    for (unsigned classIndex = 0;classIndex < classCount;++classIndex) {
        Class class = allClasses[classIndex];
        if (class_conformsToProtocol(class, @protocol(ZFAnalyticsInjectProtocol))) {
            //如果class实现了ZFAnalyticsInjectProtocol
            [allAopClass addObject:NSStringFromClass(class)];
        }
    }
    
    //使用了Aop的类
    NSMutableDictionary *usedAopClass = [[NSMutableDictionary alloc] init];
    //遍历所有的类
    for (unsigned classIndex = 0;classIndex < classCount;++classIndex) {
        Class class = allClasses[classIndex];
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            const char *attributes = property_getAttributes(properties[i]);
            NSString *attributesStr = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            NSArray *attributesList = [attributesStr componentsSeparatedByString:@","];
            if (ZFJudgeNSArray(attributesList)) {
                if ([attributesList count]) {
                    NSString *firstPropertyName = [attributesList firstObject];
                    if ([firstPropertyName rangeOfString:@"@\""].location != NSNotFound) {
                        NSString *propertyName = [firstPropertyName substringWithRange:NSMakeRange(3, firstPropertyName.length - 4)];
                        if ([allAopClass containsObject:propertyName]) {
                            YWLog(@"analyticsTest ------ %@", propertyName);
                            usedAopClass[propertyName] = NSStringFromClass(class);
                        }
                    }
                }
            }
        }
        free(properties);
    }
    
    NSMutableArray *unFindList = [[NSMutableArray alloc] init];
    //遍历ZFAnalyticsInjectProtocol class集合
    for (int i = 0; i < [allAopClass count]; i++) {
        NSString *aopklass = allAopClass[i];
        id<ZFAnalyticsInjectProtocol> klass = [[NSClassFromString(aopklass) alloc] init];
        YWLog(@"analytics init klass ------ %@", klass);
        NSDictionary *params = [klass injectMenthodParams];
        NSMutableArray *whiteList = [[NSMutableArray alloc] init];
        //        if ([klass respondsToSelector:@selector(whiteListAssert)]) {
        //            NSArray *klassWhitList = [klass whiteListAssert];
        //            [whiteList addObjectsFromArray:klassWhitList];
        //        }
        [whiteList addObjectsFromArray:[self whiteList]];
        NSArray *paramsAllKeys = [params allKeys];
        
        NSString *usedAopklass = usedAopClass[NSStringFromClass(klass.class)];
        if (usedAopklass) {
            unsigned int count = 0;
            Method *methods = class_copyMethodList(NSClassFromString(usedAopklass), &count);
            NSMutableDictionary *methodIndexParams = [[NSMutableDictionary alloc] init];
            //遍历class集合的方法列表并取出
            for (int j = 0; j < count; j++) {
                Method method = methods[j];
                SEL selector = method_getName(method);
                methodIndexParams[NSStringFromSelector(selector)] = [NSNumber numberWithInt:j];
            }
            //匹配Aop类与class集合的方法列表，排查
            for (int k = 0; k < [paramsAllKeys count]; k++) {
                NSString *injectSelector = paramsAllKeys[k];
                NSNumber *index = methodIndexParams[injectSelector];
                if (!index) {
                    if (![whiteList containsObject:injectSelector]) {
                        //白名单方法，人为的插入过
                        NSString *assertMessage = [NSString stringWithFormat:@"aop class [%@] target class [%@] not found selector [%@]", aopklass, usedAopklass, injectSelector];
                        [unFindList addObject:assertMessage];
                    }
                }
            }
            free(methods);
        }
    }
    
    if ([unFindList count]) {
        hasSuccess = NO;
        YWLog(@"单元测试(统计）:发现如下控制器中的方法未找到");
        [unFindList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YWLog(@"%@", obj);
        }];
    }
    
    XCTAssertTrue(hasSuccess, @" ======= 单元测试(统计） ======= 发现如下控制器中的方法未找到");

}

- (NSArray *)whiteList {
    return @[@"collectionView:willDisplayCell:forItemAtIndexPath:",
             @"tableView:willDisplayCell:forRowAtIndexPath:"];
}
@end
