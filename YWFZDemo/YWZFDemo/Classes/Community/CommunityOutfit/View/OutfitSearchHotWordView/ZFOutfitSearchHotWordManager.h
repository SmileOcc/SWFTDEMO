//
//  ZFOutfitSearchHotWordManager.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYModel.h"

@class HotWordModel;
@class ZFOutfitSearchHotWordManager;

@protocol ZFOutfitSearchHotWordManagerDelegate <NSObject>

- (void)ZFOutfitSearchHotWordEndSearch:(ZFOutfitSearchHotWordManager *)manager;

- (void)ZFOutfitSearchHotWordStartSearch:(ZFOutfitSearchHotWordManager *)manager
                               matchList:(NSArray <HotWordModel *> *)list
                            matchKeyword:(NSString *)keyword;

- (void)ZFOutfitSearchHotWordDidChangeAttribute:(NSAttributedString *)attribute;

@end

@interface ZFOutfitSearchHotWordManager : NSObject

@property (nonatomic, assign) BOOL hasRequest;

/// 匹配词
@property (nonatomic, copy) NSString *compareKey;

@property (nonatomic, weak) id<ZFOutfitSearchHotWordManagerDelegate>delegate;

+ (instancetype)manager;

///保存热词列表
+ (void)saveHotWordList:(NSArray <HotWordModel*> *)hotLists;

///获取热词列表
- (NSArray<HotWordModel *> *)getLocalHotWordList;

///模糊匹配
- (NSArray *)matchHotWordList:(NSString *)word;

///精准匹配
- (NSString *)matchHotWord:(NSString *)word;

///模糊匹配字符 匹配词 高亮处理
+ (NSArray *)handlerHotWordHighLightKey:(NSArray *)wordList wordKey:(NSString *)key;

/*
 * 从字符串中，查找热词规则匹配字段
 * 热词规则 '^#[A-Za-z0-9]/ /$'
 */
+ (NSArray <NSTextCheckingResult *>*)queryHotWordInString:(NSString *)string;

///监控textView输入
- (void)searchTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

///监控textView输入
- (void)searchTextViewDidChange:(UITextView *)textView;

///
- (void)searchTextViewDidEndEditing:(UITextView *)textView;

- (void)replaceInputKeyWithMatchKey:(NSString *)inputString matchKey:(NSString *)matchKey;

@end

@interface HotWordModel : NSObject<YYModel, NSCoding>

@property (nonatomic, copy) NSString *label;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSAttributedString *keyWordAttributeString;

@end

