//
//  ZFVideoLiveCommentUtils.m
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveCommentUtils.h"

@implementation ZFVideoLiveCommentUtils

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static ZFVideoLiveCommentUtils *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFVideoLiveCommentUtils alloc] init];
    });
    return instance;
}

+ (NSString *)formatNumberStr:(NSString *)string {
    if (ZFIsEmptyString(string)) {
        return @"";
    }
    if ([string isEqualToString:@"0"]) {
        return @"";
    }
    return [NSStringUtils formatKMString:string];
}

+ (NSString *)handleUserName:(NSString *)string {
    if (!ZFIsEmptyString(string)) {
        NSInteger length = string.length;
        NSString *first = [string substringToIndex:1];
        NSString *str;
        if (string.length > 1) {
            NSString *last = [string substringFromIndex:length - 1];
            str = [NSString stringWithFormat:@"%@*****%@",first,last];
        } else {
            str = first;
        }
        return str;
    }
    return @"ZZZZZ";
}

- (void)addMessage:(ZFZegoMessageInfo *)messageInfo {
    
    // 评论列表只显示这几种消息
    if([messageInfo isKindOfClass:[ZFZegoMessageInfo class]]) {
        ZFZegoMessageInfo *commonMessageInfo = (ZFZegoMessageInfo *)messageInfo;
        
        if (commonMessageInfo.infoType == ZegoMessageInfoTypeCart
            || commonMessageInfo.infoType == ZegoMessageInfoTypeOrder
            || commonMessageInfo.infoType == ZegoMessageInfoTypePay) {
            
            [self.topShowMessageList addObject:commonMessageInfo];
            [self refreshOrderPayCartNotif:commonMessageInfo];
            
        } else if(commonMessageInfo.infoType == ZegoMessageInfoTypeComment
                  || commonMessageInfo.infoType == ZegoMessageInfoTypeSystem
                  || commonMessageInfo.infoType == ZegoMessageInfoTypeUser) {
            
            [self.liveMessageList addObject:commonMessageInfo];
            [self refreshCommentNotif:messageInfo];
        }
    }
}

- (void)refreshLikeNumsAnimate:(BOOL)animated {
    if (self.likeNums > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveLikeNotification object:[NSNumber numberWithBool:animated]];
    }
}

- (void)refreshCommentNotif:(NSObject *)messageInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveAddMessageNotification object:messageInfo];
}

- (void)refreshOrderPayCartNotif:(NSObject *)messageInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveOrderPayCartNotification object:messageInfo];
}

- (void)refreshInputTextNotif {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveCommentInputTextNotification object:nil];
}

- (void)sendCommentSuccessNotif {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveCommentSendTextNotification object:nil];
}

/** 发送在线人数*/
- (void)sendOnlineCountNotif:(int)onlineCount {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoLiveOnlineCountNotification object:@(onlineCount)];
}

- (NSMutableArray *)historyMessageList {
    if (!_historyMessageList) {
        _historyMessageList = [[NSMutableArray alloc] init];
    }
    return _historyMessageList;
}

- (NSMutableArray *)liveMessageList {
    if (!_liveMessageList) {
        _liveMessageList = [[NSMutableArray alloc] init];
    }
    return _liveMessageList;
}

- (NSMutableArray<ZFZegoMessageInfo *> *)topShowMessageList {
    if (!_topShowMessageList) {
        _topShowMessageList = [[NSMutableArray alloc] init];
    }
    return _topShowMessageList;
}

- (NSString *)nickName {
    return [ZFZegoSettings sharedInstance].userName;

}


- (void)removeAllMessages {
    self.inputText = @"";
    [self.liveMessageList removeAllObjects];
    [self.topShowMessageList removeAllObjects];
    [self.historyMessageList removeAllObjects];
    self.topShowIndex = 0;
    self.likeNums = 0;
    self.onlineNums = 0;
    self.roomId = @"";
    self.liveType = @"";
    self.isLoginRoom = NO;
    self.liveDetailID = @"";
    self.isLoadingRequest = NO;
    self.isLiveConnecting = NO;
    self.isTopMessageMoving = NO;
}
@end
