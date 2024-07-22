//
//  ZFCommunityTopicDetailBaseSection.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFTopicSectionType) {
    ZFTopicSectionTypePic = 0,     // 详情图片
    ZFTopicSectionTypeDescrip,     // 标签和内容
    ZFTopicSectionTypeUserInfo,    // 用户信息
    ZFTopicSectionTypeSimilar,     // 同款商品
    ZFTopicSectionTypeRelated,     // 相关商品
    ZFTopicSectionTypeReview       // 评论

};

@interface ZFCommunityTopicDetailBaseSection : NSObject

@property (nonatomic, assign) ZFTopicSectionType            type;
@property (nonatomic, assign) CGSize                        headerSize;
@property (nonatomic, assign) CGSize                        footerSize;
@property (nonatomic, assign) UIEdgeInsets                  edgeInsets;
@property (nonatomic, assign) CGFloat                       minimumLineSpacing;      // 纵向距离
@property (nonatomic, assign) CGFloat                       minimumInteritemSpacing; // 横向距离
@property (nonatomic, assign, readonly) NSInteger           rowCount;
@property (nonatomic, assign) CGSize                        itemSize;
@property (nonatomic, assign) NSInteger                     columnCount;



- (void)setRowCount:(NSInteger)rowCount;

@end
