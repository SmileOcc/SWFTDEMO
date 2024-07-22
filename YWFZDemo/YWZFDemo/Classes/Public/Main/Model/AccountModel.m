//
//  Account.m
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "AccountModel.h"
#import "YWCFunctionTool.h"

@implementation AccountModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    AccountModel *copy = [[[self class] allocWithZone:zone] init];
    copy.sex = self.sex;
    copy.email = [self.email mutableCopy];
    copy.firstname = [self.firstname mutableCopy];
    copy.lastname = [self.firstname mutableCopy];
    copy.nickname = [self.nickname mutableCopy];
    copy.addressId = [self.addressId mutableCopy];
    copy.phone = [self.phone mutableCopy];
    copy.birthday = [self.birthday mutableCopy];
    copy.avatar = [self.avatar mutableCopy];
    copy.sess_id = [self.sess_id mutableCopy];
    copy.token = [self.token mutableCopy];
    copy.user_id = [self.user_id mutableCopy];
    copy.point_tips = [self.point_tips mutableCopy];
    copy.has_new_coupon = [self.has_new_coupon mutableCopy];
    copy.not_paying_order = [self.not_paying_order mutableCopy];
    copy.paid_order_number = [self.paid_order_number mutableCopy];
    copy.webf_email = [self.webf_email mutableCopy];
    copy.webf_email_sign = [self.webf_email_sign mutableCopy];
    copy.webf_email_sign_expire = [self.webf_email_sign_expire mutableCopy];
    copy.order_number = [self.order_number mutableCopy];
    copy.coupon_number = [self.coupon_number mutableCopy];
    copy.collect_number = [self.collect_number mutableCopy];
    copy.avaid_point = [self.avaid_point mutableCopy];

    copy.is_guest = self.is_guest;
    copy.student_level = self.student_level;
    copy.fbuid = self.fbuid;
    copy.link_id = [self.link_id mutableCopy];
    return copy;
}

- (NSString *)user_id {
    if (!_user_id) {
        _user_id = @"";
    }
    return _user_id;
}

- (NSString *)token {
    if (!_token) {
        _token = @"";
    }
    return _token;
}

- (UserEnumSexType)sex {
    if (_sex == 0) {
        //如果本身sex == 0 就取谷歌和facebook的性别
        if (ZFToString(_googleLoginGender).length) {
            return _googleLoginGender.integerValue;
        }else if (ZFToString(_facebookLoginGender).length){
            return _facebookLoginGender.integerValue;
        }else{
            //最后没有取到就返回 0
            return 0;
        }
    }else{
        return _sex;
    }
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userid"      : @"user_id",
             @"addressId"   : @"address_id",
             @"isValidated" : @"is_validated",
             };
}

-(NSString *)birthday
{
    if (ZFToString(_birthday).length) {
        return _birthday;
    }else if (ZFToString(_googleLoginBirthday).length) {
        return _googleLoginBirthday;
    }else if (ZFToString(_facebookLoginBirthday).length) {
        return _facebookLoginBirthday;
    }else{
        return @"";
    }
}

@end
