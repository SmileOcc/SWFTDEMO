//
//  ZFCommunityTopicDetailDescripSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailDescripSection.h"
#import "ZFFrameDefiner.h"

@interface ZFCommunityTopicDetailDescripSection ()

@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation ZFCommunityTopicDetailDescripSection

- (instancetype)init {
    if (self = [super init]) {
        self.type = ZFTopicSectionTypeDescrip;
        self.contentHeight = 14 + 12 + 12;  // 阅读数、发布时间高度和上下间隔
    }
    return self;
}

- (void)updateTitle:(NSString *)title contentDesc:(NSString *)contentDesc deeplinkUrl:(NSString *)linkUrl deeplinkTitle:(NSString *)linkTitle tags:(NSArray *)tagArray readNumber:(NSString *)readNumber publishTime:(NSString *)publishTime {
    
    self.title = title;
    self.topicContentString = contentDesc;
    self.deeplinkUrl = linkUrl;
    self.deeplinkTitle = linkTitle;
    self.tagArray = tagArray;
    self.readNumberString = readNumber;
    self.publishTimeString = publishTime;
    
}

#pragma mark - Property Method

- (void)setTopicContentString:(NSString *)topicContentString {
    NSString *tmpString = [topicContentString stringByReplacingOccurrencesOfString:@" " withString:@""];
    tmpString  = [tmpString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //上间隙及高端
    if ([tmpString length] > 0
        || [self.title length] > 0) {
        self.contentHeight += 12.0f;        
        _topicContentString = topicContentString;

        if ([self.title length] > 0) {
            NSMutableString *string = [NSMutableString new];
            [string appendString:self.title];
            if ([_topicContentString length] > 0) {
                [string appendString:@"\n"];
            }
            [string appendString:_topicContentString];
            _topicContentString = string;
        }
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGSize size = [_topicContentString boundingRectWithSize:CGSizeMake(KScreenWidth - 24.0, MAXFLOAT) options:options attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} context:nil].size;
        CGFloat height     = round(size.height) + 1;
        self.contentHeight += height;
    }
    self.headerSize = CGSizeMake(KScreenWidth, self.contentHeight);
}

- (void)setDeeplinkUrl:(NSString *)deeplinkUrl {
    _deeplinkUrl = deeplinkUrl;
    //上间隙及高端
    if ([deeplinkUrl length] > 0) {
        self.contentHeight += [self.topicContentString length] > 0 ? 6 : 12.0f;
        self.contentHeight += 16;
    }
    self.headerSize = CGSizeMake(KScreenWidth, self.contentHeight);
}


- (void)setTagArray:(NSArray *)tagArray {
    _tagArray = tagArray;
    
    CGFloat columnWidth = 12.0;
    
    for (NSInteger i = 0; i < tagArray.count; i++) {
        NSString *keyString = tagArray[i];
        CGSize size = [keyString sizeWithAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12.0] }];
        columnWidth += (size.width + 1.0);
        if (columnWidth + 12.0 > KScreenWidth) {
            self.contentHeight += 14.0f;
            self.contentHeight += 6.0f;
            columnWidth = 12.0 + size.width + 1.0;
            
            // 兼容最后一个刚好需要换行的情况
            if (i == tagArray.count - 1) {
                self.contentHeight += 14.0f;
                self.contentHeight += 12.0f;
            }
        } else if (i == tagArray.count - 1) {
            self.contentHeight += 14.0f;
            self.contentHeight += 12.0f;
        }
        columnWidth += 12.0f;
    }
    self.headerSize = CGSizeMake(KScreenWidth, self.contentHeight);
    
    // 减去时间相关
    self.previewHeaderSize = CGSizeMake(KScreenWidth, self.contentHeight - 14.0 - 12.0);
}


@end
