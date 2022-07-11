//
//  Account.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "AccountModel.h"

#define USER_ID @"userid"
#define USER_FIRSTNAME @"nickName"
#define USER_EMAIL @"email"
#define USER_SEX @"sex"
#define USER_AVATAR @"avatar"
#define USER_BIRTHDAY @"birthday"
#define USER_NEWCOUPONS @"appUnreadCouponNum"
#define USER_UNUSED_COUPONS @"appUnusedCouponNum"

#define USER_OUTSTANDING_ORDER_NUM @"outstandingOrderNum"
#define USER_PROCESSING_ORDER_NUM  @"processingOrderNum"
#define USER_IS_FIRST_ORDER_TIME  @"is_first_order_time"
#define USER_SHIPPED_ORDER_NUM     @"shippedOrderNum"
#define USER_REVIEWED_NUM          @"reviewedNum"

#define USER_TOKEN_STRING     @"token"
#define USER_CHECK_IN_MARK    @"checkInMark"
#define USER_AVAILABLE_COIN   @"coinCount"
#define USER_COIN_CENTER      @"coinCenter"
#define USER_MAP_CHECK        @"mapCheck"
#define USER_FEEDBACKCOUNT    @"USER_FEEDBACKCOUNT"
#define USER_PHONE            @"phone"
#define USER_PHONE_CODE       @"phone_Code"
#define USER_BIND_PHONE_AVAILABLE  @"bind_phone_available"
#define USER_TIPS             @"tips"
#define USER_IS_KOL             @"USER_IS_KOL"
#define IS_SHOW_VIP             @"IS_SHOW_MEMBER"
#define VIP_URL             @"VIP_URL"
#define VIP_ICON_URL             @"VIP_ICON_URL"
#define USER_Verif_PHONE             @"USER_Verif_PHONE"
#define USER_Bind_PHONE             @"USER_Bind_PHONE"
#define USER_BindText_PHONE             @"USER_BindText_PHONE"
#define USER_COLLECT_NUM             @"Collect_num"
#define Has_New_Coin             @"has_new_coin"
#define USER_SUBSCRIBE           @"user_subscribe" //用户订阅WhatsApp 信息
@implementation AccountModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.userid] ? @"" : self.userid forKey:USER_ID];
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.nickName] ? @"" : self.nickName forKey:USER_FIRSTNAME];
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.email] ? @"" : self.email forKey:USER_EMAIL];
    [aCoder encodeInt:self.sex forKey:USER_SEX];
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.avatar] ? @"" : self.avatar forKey:USER_AVATAR];
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.birthday] ? @"" : self.birthday forKey:USER_BIRTHDAY];
    [aCoder encodeInteger:self.appUnreadCouponNum  forKey:USER_NEWCOUPONS];
    [aCoder encodeInteger:self.appUnusedCouponNum  forKey:USER_UNUSED_COUPONS];
    [aCoder encodeInteger:self.collect_num  forKey:USER_COLLECT_NUM];
    [aCoder encodeInteger:self.outstandingOrderNum forKey:USER_OUTSTANDING_ORDER_NUM];
    [aCoder encodeInteger:self.processingOrderNum  forKey:USER_PROCESSING_ORDER_NUM];
    [aCoder encodeInteger:self.shippedOrderNum     forKey:USER_SHIPPED_ORDER_NUM];
    [aCoder encodeInteger:self.is_first_order_time forKey:USER_IS_FIRST_ORDER_TIME];
    [aCoder encodeInteger:self.reviewedNum         forKey:USER_REVIEWED_NUM];
    [aCoder encodeInteger:self.checkInMark         forKey:USER_CHECK_IN_MARK];
    [aCoder encodeInteger:self.coinCount           forKey:USER_AVAILABLE_COIN];
    [aCoder encodeObject:[OSSVNSStringTool isEmptyString:self.coinCenterUrlStr] ? @"" : self.coinCenterUrlStr forKey:USER_COIN_CENTER];
    [aCoder encodeObject:self.token forKey:USER_TOKEN_STRING];
    [aCoder encodeInteger:self.mapCheck forKey:USER_MAP_CHECK];
    [aCoder encodeInteger:self.feedbackMessageCount forKey:USER_FEEDBACKCOUNT];
    [aCoder encodeObject:self.phone forKey:USER_PHONE];
    [aCoder encodeObject:self.phoneCode forKey:USER_PHONE_CODE];
    [aCoder encodeInteger:self.bindPhoneAvailable forKey:USER_BIND_PHONE_AVAILABLE];
    [aCoder encodeObject:self.tipDic forKey:USER_TIPS];
    [aCoder encodeBool:self.is_kol forKey:USER_IS_KOL];
    [aCoder encodeBool:self.is_show_vip forKey:IS_SHOW_VIP];
    [aCoder encodeObject:STLToString(self.vip_url) forKey:VIP_URL];
    [aCoder encodeObject:STLToString(self.vip_icon_url) forKey:VIP_ICON_URL];
    [aCoder encodeInteger:self.is_verif_phone forKey:USER_Verif_PHONE];
    [aCoder encodeInteger:self.is_bind_phone forKey:USER_Bind_PHONE];
    [aCoder encodeObject:self.bind_phone_award forKey:USER_BindText_PHONE];
    [aCoder encodeBool:self.has_new_coin forKey:Has_New_Coin];
    [aCoder encodeObject:self.subscribeDic forKey:USER_SUBSCRIBE];


}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.userid               = [aDecoder decodeObjectForKey:USER_ID];
        self.token                = [aDecoder decodeObjectForKey:USER_TOKEN_STRING];
        self.nickName             = [aDecoder decodeObjectForKey:USER_FIRSTNAME];
        self.email                = [aDecoder decodeObjectForKey:USER_EMAIL];
        self.sex                  = [aDecoder decodeIntForKey:USER_SEX];
        self.avatar               = [aDecoder decodeObjectForKey:USER_AVATAR];
        self.birthday             =  [aDecoder decodeObjectForKey:USER_BIRTHDAY];
        self.appUnreadCouponNum   = [aDecoder decodeIntegerForKey:USER_NEWCOUPONS];
        self.appUnusedCouponNum   = [aDecoder decodeIntegerForKey:USER_UNUSED_COUPONS];
        self.collect_num          = [aDecoder decodeIntegerForKey:USER_COLLECT_NUM];
        self.outstandingOrderNum  = [aDecoder decodeIntegerForKey:USER_OUTSTANDING_ORDER_NUM];
        self.processingOrderNum   = [aDecoder decodeIntegerForKey:USER_PROCESSING_ORDER_NUM];
        self.shippedOrderNum      = [aDecoder decodeIntegerForKey:USER_SHIPPED_ORDER_NUM];
        self.is_first_order_time  = [aDecoder decodeIntegerForKey:USER_IS_FIRST_ORDER_TIME];
        self.reviewedNum          = [aDecoder decodeIntegerForKey:USER_REVIEWED_NUM];
        self.checkInMark          = [aDecoder decodeIntegerForKey:USER_CHECK_IN_MARK];
        self.coinCount            = [aDecoder decodeIntegerForKey:USER_AVAILABLE_COIN];
        self.coinCenterUrlStr     = [aDecoder decodeObjectForKey:USER_COIN_CENTER];
        self.mapCheck             = [aDecoder decodeIntegerForKey:USER_MAP_CHECK];
        self.feedbackMessageCount = [aDecoder decodeIntegerForKey:USER_FEEDBACKCOUNT];
        self.phone                = [aDecoder decodeObjectForKey:USER_PHONE];
        self.phoneCode            = [aDecoder decodeObjectForKey:USER_PHONE_CODE];
        self.bindPhoneAvailable   = [aDecoder decodeIntForKey:USER_BIND_PHONE_AVAILABLE];
        self.tipDic               = [aDecoder decodeObjectForKey:USER_TIPS];
        self.is_kol               = [aDecoder decodeBoolForKey:USER_IS_KOL];
        self.is_show_vip          = [aDecoder decodeBoolForKey:IS_SHOW_VIP];
        self.vip_url              = [aDecoder decodeObjectForKey:VIP_URL];
        self.vip_icon_url         = [aDecoder decodeObjectForKey:VIP_ICON_URL];
        self.is_verif_phone       = [aDecoder decodeIntegerForKey:USER_Verif_PHONE];
        self.is_bind_phone        = [aDecoder decodeIntegerForKey:USER_Bind_PHONE];
        self.bind_phone_award     = [aDecoder decodeObjectForKey:USER_BindText_PHONE];
        self.has_new_coin         = [aDecoder decodeBoolForKey:Has_New_Coin];
        self.subscribeDic       = [aDecoder decodeObjectForKey:USER_SUBSCRIBE];

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    AccountModel *copy           = [[[self class] allocWithZone:zone] init];
    copy.userid                  = [self.userid copy];
    copy.token                   = [self.token copy];
    copy.nickName                = [self.nickName copy];
    copy.email                   = [self.email copy];
    copy.sex                     = self.sex;
    copy.avatar                  = [self.avatar copy];
    copy.birthday                = [self.birthday copy];
    copy.appUnreadCouponNum      = self.appUnreadCouponNum;
    copy.appUnusedCouponNum      = self.appUnusedCouponNum;
    copy.collect_num             = self.collect_num;
    copy.outstandingOrderNum     = self.outstandingOrderNum;
    copy.processingOrderNum      = self.processingOrderNum;
    copy.shippedOrderNum         = self.shippedOrderNum;
    copy.reviewedNum             = self.reviewedNum;
    copy.checkInMark             = self.checkInMark;
    copy.coinCount               = self.coinCount;
    copy.coinCenterUrlStr        = self.coinCenterUrlStr;
    copy.mapCheck                = self.mapCheck;
    copy.is_first_order_time     = self.is_first_order_time;
    copy.feedbackMessageCount    = self.feedbackMessageCount;
    copy.phone                   = self.phone;
    copy.phoneCode               = self.phoneCode;
    copy.bindPhoneAvailable      = self.bindPhoneAvailable;
    copy.tipDic                  = self.tipDic;
    copy.is_kol                  = self.is_kol;
    copy.is_show_vip             = self.is_show_vip;
    copy.vip_url                 = self.vip_url;
    copy.vip_icon_url            = self.vip_icon_url;
    copy.is_verif_phone          = self.is_verif_phone;
    copy.is_bind_phone           = self.is_bind_phone;
    copy.bind_phone_award        = self.bind_phone_award;
    copy.has_new_coin            = self.has_new_coin;
    copy.subscribeDic            = self.subscribeDic;
    
    return copy;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    AccountModel *copy           = [[[self class] allocWithZone:zone] init];
    copy.userid                  = [self.userid mutableCopy];
    copy.token                   = [self.token mutableCopy];
    copy.nickName                = [self.nickName mutableCopy];
    copy.email                   = [self.email mutableCopy];
    copy.sex                     = self.sex;
    copy.avatar                  = [self.avatar mutableCopy];
    copy.birthday                = [self.birthday mutableCopy];
    copy.appUnreadCouponNum      = self.appUnreadCouponNum;
    copy.appUnusedCouponNum      = self.appUnusedCouponNum;
    copy.outstandingOrderNum     = self.outstandingOrderNum;
    copy.processingOrderNum      = self.processingOrderNum;
    copy.shippedOrderNum         = self.shippedOrderNum;
    copy.reviewedNum             = self.reviewedNum;
    copy.checkInMark             = self.checkInMark;
    copy.coinCount               = self.coinCount;
    copy.coinCenterUrlStr        = self.coinCenterUrlStr;
    copy.mapCheck                = self.mapCheck;
    copy.is_first_order_time     = self.is_first_order_time;
    copy.feedbackMessageCount    = self.feedbackMessageCount;
    copy.phone                   = self.phone;
    copy.phoneCode               = self.phoneCode;
    copy.bindPhoneAvailable      = self.bindPhoneAvailable;
    copy.tipDic                  = self.tipDic;
    copy.is_kol                  = self.is_kol;
    copy.is_show_vip             = self.is_show_vip;
    copy.vip_url                 = self.vip_url;
    copy.vip_icon_url            = self.vip_icon_url;
    copy.is_verif_phone          = self.is_verif_phone;
    copy.is_bind_phone           = self.is_bind_phone;
    copy.bind_phone_award        = self.bind_phone_award;
    copy.has_new_coin            = self.has_new_coin;
    copy.subscribeDic            = self.subscribeDic;
    
    return copy;
}

- (NSString *) description{
    NSString* descriptionString = [NSString stringWithFormat:@"userid:%@ \n token:%@ \n nickName:%@ \n email:%@ \n sex:%ld \n avatar:%@ \n birthday:%@  appUnreadCouponNum:%ld \n outstandingOrderNum:%ld \n is_first_order_time:%ld \n phone:%@ \n phoneCode:%@", self.userid, self.token, self.nickName, self.email, (unsigned long)self.sex, self.avatar,self.birthday,(long)self.appUnreadCouponNum,self.outstandingOrderNum,self.is_first_order_time, self.phone, self.phoneCode];
    
    return descriptionString;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userid"              : @"user_id",
             @"token"               : @"token",
             @"nickName"            : @"nick_name",
             @"sex"                 : @"sex",
             @"email"               : @"email",
             @"birthday"            : @"birthday",
             @"avatar"              : @"avatar",
             @"appUnreadCouponNum"  : @"appUnreadCouponNum",
             @"outstandingOrderNum" : @"outstandingOrderNum",
             @"processingOrderNum"  : @"processingOrderNum",
             @"shippedOrderNum"     : @"shippedOrderNum",
             @"reviewedNum"         : @"reviewedNum",
             @"feedbackMessageCount": @"feedbackMessageCount",
             @"checkInMark"         : @"is_check_in",
             @"coinCount"           : @"available_coin",
             @"coinCenterUrlStr"    : @"coin_center_url",
             @"mapCheck"            : @"mapCheck",
             @"phone"               : @"phone",
             @"phoneCode"           : @"phone_code",
             @"bindPhoneAvailable"  : @"bind_phone_available",
             @"tipDic"              : @"tips",
             @"is_kol"              : @"is_kol",
             @"is_show_vip"         :  @"is_show_vip",
             @"vip_url"             : @"vip_url",
             @"vip_icon_url"        : @"vip_icon_url",
             @"is_verif_phone"      : @"is_verif_phone",
             @"is_bind_phone"       : @"is_bind_phone",
             @"bind_phone_award"    : @"bind_phone_award",
             @"subscribeDic"      : @"what_apps_subscribe"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"userid",
             @"token",
             @"nickName",
             @"email",
             @"sex",
             @"avatar",
             @"birthday",
             @"appUnreadCouponNum",
             @"outstandingOrderNum",
             @"is_new",
             @"processingOrderNum",
             @"shippedOrderNum",
             @"reviewedNum",
             @"feedbackMessageCount",
             @"checkInMark",
             @"coinCount",
             @"coinCenterUrlStr",
             @"mapCheck",
             @"is_first_order_time",
             @"phone",
             @"phoneCode",
             @"bindPhoneAvailable",
             @"tipDic",
             @"is_kol",
             @"is_show_vip",
             @"vip_url",
             @"vip_icon_url",
             @"is_verif_phone",
             @"is_bind_phone",
             @"bind_phone_award",
             @"collect_num",
             @"appUnusedCouponNum",
             @"has_new_coin",
             @"subscribeDic"
             ];
}

/**
 *  此处方法做数据校验，可以设置默认值
 *
 *  @param dic 需要解析的字典
 *
 *  @return 是否符合条件
 */
//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
////    NSString *isValidated = dic[@"is_validated"];
////    if (isValidated == nil) {
////        self.isValidated = @"0";
////    }
////    NSString *avaidPoint = dic[@"avaid_point"];
////    if (avaidPoint == nil) {
////        self.avaidPoint = @"0";
////    }
////    NSString *ordersCount = dic[@"orders_count"];
////    if (ordersCount == nil) {
////        self.ordersCount = @"0";
////    }
////    NSString *favoriteCount = dic[@"favorite_count"];
////    if (favoriteCount == nil) {
////        self.favoriteCount = @"0";
////    }
////    NSString *reviewCont = dic[@"review_cont"];
////    if (reviewCont == nil) {
////        self.reviewCont = @"0";
////    }
//
//    NSString *firstname = dic[@"firstname"];
//    if (firstname == nil || [firstname isKindOfClass:[NSNull class]]) {
//        self.firstname = [OSSVAccountsManager sharedManager].account.firstname;
//    }
//    return YES;
//}

@end
