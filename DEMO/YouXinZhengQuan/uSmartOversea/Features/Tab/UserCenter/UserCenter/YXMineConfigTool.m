
//
//  YXMineConfigTool.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXMineConfigTool.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXMineConfigTool()

@property (nonatomic, strong) NSString *dataVersion;

@property (nonatomic, strong) YXMineConfigModuleModel *defaultModel;

@end

static NSString *mineConfigUIKey = @"mineConfigUIKey_V1";

@implementation YXMineConfigTool

- (instancetype)init {
    if (self =  [super init]) {
        self.dataVersion = @"0";
    }
    return self;
}

- (void)loadDataWithSuccess:(void (^) (BOOL isModified, YXMineConfigModel *configModel))callBack {
    
    YXMineConfigRequestModel *requestModel = [[YXMineConfigRequestModel alloc] init];
    requestModel.dataVersion = self.dataVersion;
    YXRequest *requset = [[YXRequest alloc] initWithRequestModel:requestModel];
    
    [requset startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
        BOOL modified = [responseModel.data yx_boolValueForKey:@"modified"];
        if (modified) {
            [[MMKV defaultMMKV] setObject:responseModel.data forKey:mineConfigUIKey];
            self.dataVersion = [responseModel.data yx_stringValueForKey:@"dataVersion" defaultValue:@"0"];
            NSDictionary *data = [responseModel.data yx_dictionaryValueForKey:@"data"];
            self.configModel = [YXMineConfigModel yy_modelWithJSON:data];
            NSMutableArray *arr = [NSMutableArray array];
            if (self.configModel.modules.count > 0) {
                [arr addObjectsFromArray:self.configModel.modules];
            }
            
            for (YXMineConfigModuleModel *module in arr) {
                if (module.redDotType == 1) {
                    // 活动的小红点
                    module.redDotEnabled = ![[YXLittleRedDotManager shared] isHiddenActCenter];
                }
                for (YXMineConfigElementModel *elem in module.elements) {
                    if (elem.redDotType == 2) {
                        // 奖励中心的小红点
                        elem.redDotEnabled = ![[YXLittleRedDotManager shared] isHiddenNewCoupon];
                    }
                }
            }
            
//            [arr addObject:self.defaultModel];
            self.configModel.modules = arr;
        }
              
        if (callBack) {
            callBack(modified, self.configModel);
        }

    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (callBack) {
            callBack(NO, self.configModel);
        }
    }];
}

- (YXMineConfigModuleModel *)defaultModel {
    if (_defaultModel == nil) {
        NSDictionary *dic = @{
            @"elements": @[@{@"mainTitle": @{@"zhCHS": @"意见反馈", @"en": @"Feedback", @"zhCHT": @"意見回饋"},
                             @"logUrl": @{@"white": @"user_feedback", @"black": @"user_feedback"},
                             @"jumpUrl": [YXNativeRouterConstant GOTO_FEEDBACK],
                             @"jumpType": @"2",
                             @"redDotEnabled": @(false),
            },
                           @{@"mainTitle": @{@"zhCHS": @"帮助与客服", @"zhCHT": @"幫助與客服", @"en": @"Help Center"},
                             @"logUrl": @{@"white": @"user_help", @"black": @"user_help"},
                             @"jumpUrl": [YXNativeRouterConstant GOTO_CUSTOMER_SERVICE],
                             @"jumpType": @"2",
                             @"redDotEnabled": @(false),
                           },
                           @{@"mainTitle": @{@"zhCHS": @"关于uSMART", @"en": @"About uSMART", @"zhCHT": @"關於uSMART"},
                             @"subTitle": @{@"zhCHS": @"关于uSMART", @"en": @"About uSMART", @"zhCHT": @"關於uSMART"},
                             @"logUrl": @{@"white": @"user_about", @"black": @"user_about"},
                             @"jumpUrl": [YXNativeRouterConstant GOTO_ABOUT_DETAIL],
                             @"jumpType": @"2",
                             @"redDotEnabled": @(false),
                           }
            ],            
        };
        _defaultModel = [YXMineConfigModuleModel yy_modelWithJSON:dic];
        // 单行
        _defaultModel.moduleType = 3;
    }
    return _defaultModel;
}

- (YXMineConfigModel *)configModel {
    if (_configModel == nil) {
        _configModel = [[YXMineConfigModel alloc] init];
        
        NSDictionary *dic = [[MMKV defaultMMKV] getObjectOfClass:[NSDictionary class] forKey:mineConfigUIKey];
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSString *dataVersion = [dic yx_stringValueForKey:@"dataVersion" defaultValue:@"0"];
            self.dataVersion = dataVersion;
            NSDictionary *dataDic = [dic yx_dictionaryValueForKey:@"data"];
            _configModel = [YXMineConfigModel yy_modelWithJSON:dataDic];
        }
        NSMutableArray *arr = [NSMutableArray array];
        if (_configModel.modules.count > 0) {
            [arr addObjectsFromArray:_configModel.modules];
        }
//        [arr addObject:self.defaultModel];
        _configModel.modules = arr;
    }
    return _configModel;
}


+ (NSString *)getTitleWithModel: (YXMineConfigNameModel *)model {
    
    if ([YXUserManager curLanguage] == YXLanguageTypeCN) {
        return model.zhCHS;
    } else if ([YXUserManager curLanguage] == YXLanguageTypeEN) {
        return model.en;
    } else {
        return model.zhCHT;
    }
    
    return @"";
}


+ (NSString *)getLogUrlWithModel: (YXMineConfigLogModel *)model {
    if ([YXUserManager curLanguage] == YXLanguageTypeCN) {
        return model.cnLogo;
    } else if ([YXUserManager curLanguage] == YXLanguageTypeEN) {
        return model.enLogo;
    } else {
        return model.hkLogo;
    }
    
    return @"";
}

@end
