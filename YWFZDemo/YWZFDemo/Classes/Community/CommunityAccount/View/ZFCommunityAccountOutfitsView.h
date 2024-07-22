//
//  ZFCommunityAccountOutfitsView.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommunityAccountOutfitsDetailCompletionHandler)(NSString *userId, NSString *reviewsId, NSString *title);

@interface ZFCommunityAccountOutfitsView : UICollectionViewCell
@property (nonatomic, copy) NSString            *userId;
@property (nonatomic, weak) UIViewController    *controller;
@property (nonatomic, copy) CommunityAccountOutfitsDetailCompletionHandler  communityAccountOutfitsDetailCompletionHandler;
@end
