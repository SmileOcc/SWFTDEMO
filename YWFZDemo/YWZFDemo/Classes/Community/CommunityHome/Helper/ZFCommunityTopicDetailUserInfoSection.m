//
//  ZFCommunityTopicDetailUserInfoSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailUserInfoSection.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailUserInfoSection

- (instancetype)init {
    if (self = [super init]) {
        self.type = ZFTopicSectionTypeUserInfo;
        self.headerSize = CGSizeMake(KScreenWidth, 64.0);
        self.footerSize = CGSizeMake(KScreenWidth, 0.0);
    }
    return self;
}

@end
