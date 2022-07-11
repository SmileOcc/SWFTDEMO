//
//  OSSVAdvsEventsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAdvsEventsModel.h"

@implementation OSSVAdvsEventsModel

-(instancetype)initWhtiSpecialModel:(STLAdvEventSpecialModel *)model
{
    self = [super init];
    
    if (self) {
        self.actionType = model.pageType;
        self.url = model.url;
        self.name = model.name;
        self.imageURL = model.images;
//        self.arImageURL = model.arImages;
    }
    return self;
}

- (AdvEventType )advActionType {
    if (!STLIsEmptyString(self.url) && [self.url hasPrefix:[OSSVLocaslHosstManager appDeeplinkPrefix]]) {
        NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:self.url];
        if ([md[@"actiontype"] integerValue] > 0) {
            return [md[@"actiontype"] integerValue];
        }
    }
    return self.actionType;
}
- (NSString *)advActionUrl {
    if (!STLIsEmptyString(self.url) && [self.url hasPrefix:[OSSVLocaslHosstManager appDeeplinkPrefix]]) {
        NSMutableDictionary *md = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:self.url]];
        if ([md[@"actiontype"] integerValue] > 0) {
            return REMOVE_URLENCODING(STLToString(md[@"url"]));
        }
    }
    return STLToString(self.url);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.actionType         = [aDecoder decodeIntegerForKey:@"actionType"];
        self.url                = [aDecoder decodeObjectForKey:@"url"];
        self.name               = [aDecoder decodeObjectForKey:@"name"];
        self.startTime          = [aDecoder decodeObjectForKey:@"startTime"];
        self.endTime            = [aDecoder decodeObjectForKey:@"endTime"];
        self.bannerId           = [aDecoder decodeObjectForKey:@"bannerId"];
        self.imageURL           = [aDecoder decodeObjectForKey:@"imageURL"];
        self.isShare            = [aDecoder decodeBoolForKey:@"isShare"];
        self.shareImageURL      = [aDecoder decodeObjectForKey:@"shareImageURL"];
        self.shareTitle         = [aDecoder decodeObjectForKey:@"shareTitle"];
        self.shareLinkURL       = [aDecoder decodeObjectForKey:@"shareLinkURL"];
        self.shareDoc           = [aDecoder decodeObjectForKey:@"shareDoc"];
        self.leftTime           = [aDecoder decodeObjectForKey:@"leftTime"];
        self.serverTime         = [aDecoder decodeObjectForKey:@"serverTime"];
        self.width              = [aDecoder decodeObjectForKey:@"width"];
        self.height             = [aDecoder decodeObjectForKey:@"height"];
        self.popupNumber        = [aDecoder decodeObjectForKey:@"popupNumber"];
        self.popupShowNumber    = [aDecoder decodeObjectForKey:@"popupShowNumber"];
        self.popupType          = [aDecoder decodeObjectForKey:@"popupType"];
        self.marqueeText        = [aDecoder decodeObjectForKey:@"marquee_text"];
        self.marqueeColor       = [aDecoder decodeObjectForKey:@"marquee_color"];
        self.marqueeBgColor     = [aDecoder decodeObjectForKey:@"marquee_bg_color"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.actionType forKey:@"actionType"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.bannerId forKey:@"bannerId"];
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [aCoder encodeBool:self.isShare forKey:@"isShare"];
    [aCoder encodeObject:self.shareImageURL forKey:@"shareImageURL"];
    [aCoder encodeObject:self.shareTitle forKey:@"shareTitle"];
    [aCoder encodeObject:self.shareLinkURL forKey:@"shareLinkURL"];
    [aCoder encodeObject:self.shareDoc forKey:@"shareDoc"];
    [aCoder encodeObject:self.leftTime forKey:@"leftTime"];
    [aCoder encodeObject:self.serverTime forKey:@"serverTime"];
    [aCoder encodeObject:self.width forKey:@"width"];
    [aCoder encodeObject:self.height forKey:@"height"];
    [aCoder encodeObject:self.popupNumber forKey:@"popupNumber"];
    [aCoder encodeObject:self.popupShowNumber forKey:@"popupShowNumber"];
    [aCoder encodeObject:self.popupType forKey:@"popupType"];
    [aCoder encodeObject:self.marqueeColor forKey:@"marqueeColor"];
    [aCoder encodeObject:self.marqueeBgColor forKey:@"marqueeBgColor"];
    [aCoder encodeObject:self.marqueeText forKey:@"marqueeText"];
    

}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"actionType"               : @"actionType",
             @"endTime"                  : @"endTime",
             @"bannerId"                 : @"id",
             @"imageURL"                 : @"image_url",
             @"isShare"                  : @"is_share",
             @"leftTime"                 : @"leftTime",
             @"name"                     : @"name",
             @"serverTime"               : @"serverTime",
             @"shareTitle"               : @"share_title",
             @"shareImageURL"            : @"share_img",
             @"shareLinkURL"             : @"share_link",
             @"shareDoc"                 : @"share_doc",
             @"shop_price"           : @"shop_price",
             @"startTime"                : @"startTime",
             @"url"                      : @"url",
             @"width"                    : @"width",
             @"height"                   : @"height",
             @"popupNumber"              : @"popup_number",
             @"popupShowNumber"          : @"popupShowNumber",
             @"popupType"                : @"popup_type",
             @"marqueeColor"             : @"marquee_color",
             @"marqueeBgColor"           : @"marquee_bg_color",
             @"marqueeText"              : @"marquee_text",
             @"actionType"               : @"page_type"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist
{
    
    return  @[
              @"actionType",
              @"endTime",
              @"bannerId",
              @"imageURL",
              @"isShare",
              @"leftTime",
              @"name",
              @"serverTime",
              @"shareImageURL",
              @"shareTitle",
              @"shareLinkURL",
              @"shareDoc",
              @"shop_price",
              @"startTime",
              @"url",
              @"width",
              @"height",
              @"popupNumber",
              @"popupShowNumber",
              @"popupType",
              @"marqueeColor",
              @"marqueeBgColor",
              @"marqueeText",
              @"info",
              @"page_type",
              @"banner_name"
              ];
}

@end

//原生自定义专题跳转模型

@implementation STLAdvEventSpecialModel

@end
