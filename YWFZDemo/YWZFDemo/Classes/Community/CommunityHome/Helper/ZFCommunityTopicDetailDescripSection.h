//
//  ZFCommunityTopicDetailDescripSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"

@interface ZFCommunityTopicDetailDescripSection : ZFCommunityTopicDetailBaseSection

// 先赋值 title 后赋值 content
@property (nonatomic, copy) NSString *title;                 // 标题
@property (nonatomic, copy) NSString *topicContentString;    // 内容描述
@property (nonatomic, copy) NSString *deeplinkTitle;         //deeplink跳转标题
@property (nonatomic, copy) NSString *deeplinkUrl;           //deeplink跳转

@property (nonatomic, copy) NSArray  *tagArray;              // 标签
@property (nonatomic, copy) NSString *readNumberString;      // 阅读数
@property (nonatomic, copy) NSString *publishTimeString;     // 发布时间


@property (nonatomic, assign) CGSize                        previewHeaderSize;


- (void)updateTitle:(NSString *)title contentDesc:(NSString *)contentDesc deeplinkUrl:(NSString *)linkUrl deeplinkTitle:(NSString *)linkTitle tags:(NSArray *)tagArray readNumber:(NSString *)readNumber publishTime:(NSString *)publishTime;
@end
