//
//  NativeShareModel.m
//  ZZZZZ
//
//  Created by YW on 31/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "NativeShareModel.h"

@implementation NativeShareModel

- (NSString *)fetchSharePageTypeString
{
    NSString *sharePageType = @"";
    switch (self.sharePageType) {
        case ZFSharePage_H5_ShareType: {
            sharePageType = @"H5_Share";
        }
            break;
        case ZFSharePage_NativeBannerType: {
            sharePageType = @"ThematicTemplate";
        }
            break;
        case ZFSharePage_GroupPurchaseType: {
            sharePageType = @"GroupPurchase";
        }
            break;
        case ZFSharePage_ProductDetailType: {
            sharePageType = @"ProductDetail";
        }
            break;
        case ZFSharePage_CommunityTopicsDetailType: {
            sharePageType = @"Community_Topics_Detail";
        }
            break;
        case ZFSharePage_CommunityTopicsDetailListType: {
            sharePageType = @"Community_Topics_Detail_List";
        }
            break;
        case ZFSharePage_CommunityFavesType: {
            sharePageType = @"Community_Faves";
        }
            break;
        case ZFSharePage_CommunityPostDetailType: {
            sharePageType = @"Community_Post_Detail";
        }
            break;
        case ZFSharePage_Live_DetailType: {
            sharePageType = @"Live_Detail";
        }
            break;
        case ZFSharePage_CommunityStyleCenterType: {
            sharePageType = @"Community_Style_Center";
        }
            break;
        case ZFSharePage_CommunitySearchFriendsType: {
            sharePageType = @"Community_Search_Friends";
        }
            break;
    }
    return sharePageType;
}


@end
