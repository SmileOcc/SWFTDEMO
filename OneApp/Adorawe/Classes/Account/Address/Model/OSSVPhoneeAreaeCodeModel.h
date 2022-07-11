//
//  OSSVPhoneeAreaeCodeModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//@class STLPhoneRuleModel;


@interface STLPhoneRuleModel : NSObject<YYModel>
@property (nonatomic, copy) NSString *phoneNumberHeader;      //号码开头
@property (nonatomic, copy) NSString *phoneNumberLength; //号码长度
@property (nonatomic, copy) NSString *phoneOperatorsHeadNumbe; //运营商开头号码
@property (nonatomic, copy) NSString *phoneRemainLength; //除开头部，剩余号码长度位数
@property (nonatomic, copy) NSString *phoneErrorTextEn;  //错误提示英语
@property (nonatomic, copy) NSString *phoneErrorTextAr;  //错误提示阿语
@end



@interface OSSVPhoneeAreaeCodeModel : NSObject<YYModel>
@property (nonatomic, copy) NSString *countryAreaCode; //国家区号
@property (nonatomic, strong)STLPhoneRuleModel *ruleModel;

@end



NS_ASSUME_NONNULL_END
