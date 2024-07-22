//
//  ZFOutfitSearchHotWordManager.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOutfitSearchHotWordManager.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"

NSString * const kHotWordFolderName                 = @"HotWord";// 存储的路径文件夹名

@implementation HotWordModel

+ (instancetype)initWithKey:(NSString *)key nums:(NSUInteger)nums
{
    HotWordModel *model = [[HotWordModel alloc] init];
    model.label = key;
    model.count = nums;
    return model;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}


@end

@interface ZFOutfitSearchHotWordManager ()

@property (nonatomic, copy) NSString *inputingWord;
@property (nonatomic, assign) NSRange textViewChangeRange;          ///开始搜索range
@property (nonatomic, assign) NSRange matchWordRange;               ///匹配词range

@property (nonatomic, assign) NSRange textChangeRange;              ///每次用户输入插入值range

@property (nonatomic, assign) BOOL isStartSearch;
@property (nonatomic, assign) NSUInteger startMatchIndex;

@property (nonatomic, strong) UIFont *attriFont;

@property (nonatomic, strong) NSArray *matchList;
@end

@implementation ZFOutfitSearchHotWordManager

+ (instancetype)manager
{
    static ZFOutfitSearchHotWordManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFOutfitSearchHotWordManager alloc] init];
    });
    
    return manager;
}

// 数据保存的文件夹路径
+ (NSString *)path {
    NSString *userDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directryPath = [userDocument stringByAppendingPathComponent:kHotWordFolderName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directryPath] == NO) {
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directryPath;
}

+ (NSString *)hotModelPath {
    NSString *path = [self path];
    NSString *filePath = [path stringByAppendingPathComponent:@"ZFHotPostWord"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == NO) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    //YWLog(@"换肤数据保存路径: %@", filePath);
    return filePath;
}
+ (void)saveHotWordList:(NSArray <HotWordModel*> *)hotLists {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *skinPath = [self hotModelPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:skinPath error:nil];
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:hotLists];
        BOOL isSuccess = [modelData writeToFile:skinPath atomically:YES];
        YWLog(@"---- 热门帖子标签存储: %@",isSuccess ? @"成功" : @"失败");
    });
}

- (NSArray<HotWordModel *> *)getLocalHotWordList {
    if ([self.matchList count]) {
        return self.matchList;
    }
    NSArray *hotWordList = [NSKeyedUnarchiver unarchiveObjectWithFile:[ZFOutfitSearchHotWordManager hotModelPath]];
    self.matchList = hotWordList;
    if (!ZFJudgeNSArray(hotWordList)) {
        self.matchList = @[];
    }
    #warning TODO:xiao test
//    self.matchList = [self testWordList];
    return self.matchList;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.compareKey = @"";
    }
    return self;
}

- (NSArray *)matchHotWordList:(NSString *)word
{
//    NSArray *list = [self testWordList];
    NSArray *list = [self getLocalHotWordList];
    
//    NSArray *stringChar = [ZFOutfitSearchHotWordManager subStringList:word];
    if (!self.compareKey.length) {
        return @[];
    }
    NSMutableString *mutString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ LIKE", self.compareKey]];
    
    if ([word containsString:@"\n"]) {
        word = [word stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    [mutString appendFormat:@" '%@*'", word];
//    [mutString appendFormat:@"'*"];
//    [stringChar enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *regix = [NSString stringWithFormat:@"%@*", obj];
//        if (idx != 0) {
//            regix = [NSString stringWithFormat:@"%@*", obj];
//        }
//        [mutString appendString:regix];
//    }];
//    [mutString appendFormat:@"'"];
        
    //表达式，模糊匹配字符串是否包含所输入的文字 (输入文字可以是跨字符)
    NSString *regix = [NSString stringWithFormat:@"%@", mutString];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:regix];

    NSArray *result = [list filteredArrayUsingPredicate:predicate];
    
    result = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        HotWordModel *model1 = obj1;
        HotWordModel *model2 = obj2;
        return model1.count < model2.count;
    }];
    
//    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        HotWordModel *model = obj;
//        YWLog(@"%@ %ld", model.keyWord, model.nums.integerValue);
//    }];
    
    return result;
}

- (NSString *)matchHotWord:(NSString *)word
{
    NSArray *list = [self getLocalHotWordList];
    
    NSString *result = nil;
    
    word = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([word containsString:@"\n"]) {
        word = [word stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    NSMutableString *responseString = [NSMutableString stringWithString:word];
//    NSString *character = nil;
//    for (int i = 0; i < responseString.length; i ++) {
//        character = [responseString substringWithRange:NSMakeRange(i, 1)];
//        if ([character isEqualToString:@"\\"])
//            [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//    }
    
    NSMutableString *regix = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ LIKE '%@'", self.compareKey, responseString.copy]];
    
    regix = [NSString stringWithFormat:@"%@", word].copy;

    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:regix options:NSRegularExpressionIgnoreMetacharacters error:nil];

    for (int i = 0; i < list.count; i++) {
        HotWordModel *model = list[i];
        NSTextCheckingResult *checkResult = [regx firstMatchInString:model.label options:0 range:NSMakeRange(0, model.label.length)];
        if (checkResult.range.length == model.label.length) {
            result = model.label;
            break;
        }
    }
    return result;
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:regix];
//
//
//    NSArray *resultList = [list filteredArrayUsingPredicate:predicate];
//
//    if (resultList) {
//        result = resultList.firstObject;
//        if ([result isKindOfClass:[HotWordModel class]]) {
//            HotWordModel *model = (HotWordModel *)result;
//            result = model.label;
//        }
//    }
//    return result;
}


+ (NSArray *)handlerHotWordHighLightKey:(NSArray *)wordList wordKey:(NSString *)key
{
    NSArray *stringCharList = [self subStringList:key];
    if ([wordList count] > 20) {
        wordList = [wordList subarrayWithRange:NSMakeRange(0, 20)];
    }
    
    for (int i = 0; i < wordList.count; i++) {
        HotWordModel *model = wordList[i];
        NSString *matchKeyword = model.label;
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:matchKeyword];
        [attributeString addAttributes:@{NSForegroundColorAttributeName : ZFC0x999999()} range:NSMakeRange(0, attributeString.length)];
        for (int j = 0; j < stringCharList.count; j++) {
            NSString *charS = stringCharList[j];
            if ([matchKeyword containsString:charS]) {
                NSRange range = [matchKeyword rangeOfString:charS];
                [attributeString addAttributes:@{NSForegroundColorAttributeName : ZFC0x3D76B9()} range:range];
            }
        }
        model.keyWordAttributeString = attributeString.copy;
    }
    
    return wordList;
}

+ (NSArray <NSTextCheckingResult *>*)queryHotWordInString:(NSString *)string
{
    NSString *regix = @"[#]{1}[A-Za-z0-9]*[\\s]{1}";
    regix = @"[#]{1}[\\S]*[\\s]{1}";
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:regix options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *resultList = [reg matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return resultList;
}

+ (NSArray *)subStringList:(NSString *)key
{
    NSMutableArray *stringChar = [[NSMutableArray alloc] init];
    for (int i = 0; i < key.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *sChar = [key substringWithRange:range];
        [stringChar addObject:sChar];
    }
    return stringChar.copy;
}

#pragma mark - textView method

- (void)searchTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.inputingWord = text;
    if ([self.inputingWord isEqualToString:@"#"]) {
        //用户开始输入#号，保存#号位置，用于匹配用户输入的完整热词
        self.textViewChangeRange = range;
    }

    if (self.isStartSearch) {
        //开始匹配时，保存用户随后输入的字符长度
        NSInteger index = range.length;
        if (index == 0) {
            index = 1;
        }
        self.startMatchIndex += index;
    }

    //保存用户输入的字符 font
    self.attriFont = textView.font;

    //保存用户实时输入的长度
    self.textChangeRange = NSMakeRange(range.location, text.length);
}

- (void)searchTextViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    
    NSRange lastCharRange = self.textViewChangeRange;
    NSString *lastChar = self.inputingWord;
    
    if ([lastChar isEqualToString:@"#"]) {
        //当用户输入 #, 就开始搜索热词
        [self startSearch];
    }
    if ([lastChar isEqualToString:@" "] || [self.inputingWord isEqualToString:@"\n"]) {
        //用户输入空格，或者回车，结束搜索
        [self endSearch];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordEndSearch:)]) {
            [self.delegate ZFOutfitSearchHotWordEndSearch:self];
        }
    }
    if ([self.inputingWord isEqualToString:@""]) {
        //查找删除字符前一个字符是否是 #
        lastCharRange = NSMakeRange(self.textChangeRange.location - 1, 1);
        if (lastCharRange.location >= 0 && (text.length >= (lastCharRange.location + lastCharRange.length))) {
            NSString *preChar = [text substringWithRange:lastCharRange];
            if ([preChar isEqualToString:@"#"]) {
                //是 # 重新开始匹配
                [self startSearch];
            } else {
                [self endSearch];
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordEndSearch:)]) {
                    [self.delegate ZFOutfitSearchHotWordEndSearch:self];
                }
                return;
            }
        } else {
            return;
        }
    }
    if (self.isStartSearch) {
        //从词库中 实时匹配用户输入的词
        NSString *keyword = @"";
        if (lastCharRange.location != NSNotFound) {
            //匹配用户在输入#号以后，输入的字符
            NSRange keywordRange = NSMakeRange(lastCharRange.location, self.startMatchIndex);
            if (keywordRange.length <= text.length) {
                keyword = [text substringWithRange:keywordRange];
                self.matchWordRange = keywordRange;
            }
        }
        if (keyword.length) {
            //通过用户输入的字符，从热词表中筛选符合条件的热词
            NSArray *matchList = [self matchHotWordList:keyword];
            if ([matchList count]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordStartSearch:matchList:matchKeyword:)]) {
                    [self.delegate ZFOutfitSearchHotWordStartSearch:self matchList:matchList matchKeyword:keyword];
                }
            } else {
//                [self endSearch];
                if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordDidChangeAttribute:)]) {
                    NSAttributedString *attri = [self findHotWordAndHighLightKey:text font:textView.font keyworld:keyword];
                    [self.delegate ZFOutfitSearchHotWordDidChangeAttribute:attri];
                }
                //隐藏提示框
//                if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordEndSearch:)]) {
//                    [self.delegate ZFOutfitSearchHotWordEndSearch:self];
//                }
            }
        }
    } else {
        //用户主动结束输入热词，把用户输入的热词匹配出来并着色
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordDidChangeAttribute:)]) {
            NSRange inputRange = self.textChangeRange;
    
            NSAttributedString *attri =  nil;
            if ([self.inputingWord containsString:@"#"] || [self.inputingWord isEqualToString:@" "]) {
                //匹配用户结束搜索后，复制，或者输入的字符中是否包含 #
                attri = [self findHotWordAndHighLightKey:text font:textView.font keyworld:@""];
            } else {
                //用户正常情况输入的时候，设置字符为普通颜色
                NSMutableAttributedString *customAtt = [textView.attributedText mutableCopy];
                UIColor *textColor = [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
                [customAtt addAttributes:@{NSFontAttributeName : self.attriFont} range:inputRange];
                [customAtt addAttributes:@{NSForegroundColorAttributeName : textColor} range:inputRange];
                attri = customAtt.copy;
            }
            [self.delegate ZFOutfitSearchHotWordDidChangeAttribute:attri];
        }
    }
    if (ZFIsEmptyString(text)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordEndSearch:)]) {
            [self.delegate ZFOutfitSearchHotWordEndSearch:self];
        }
    }
}

- (void)searchTextViewDidEndEditing:(UITextView *)textView
{
    NSString *text = textView.text;
    if (ZFIsEmptyString(text)) {
        return;
    }
    if (self.isStartSearch) {
        NSRange lastCharRange = NSMakeRange(text.length - 1, 1);
        NSString *lastChar = [text substringWithRange:lastCharRange];
        if (![lastChar isEqualToString:@" "]) {
            text = [text stringByAppendingString:@" "];
        }
        NSAttributedString *attri = [self findHotWordAndHighLightKey:text font:textView.font keyworld:@""];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordDidChangeAttribute:)]) {
            [self.delegate ZFOutfitSearchHotWordDidChangeAttribute:attri];
        }
        [self endSearch];
    }
}

- (void)replaceInputKeyWithMatchKey:(NSString *)inputString matchKey:(NSString *)matchKey
{
    if (self.matchWordRange.location != NSNotFound) {
        //把用户输入的词，替换成选择的词
        NSString *text = inputString;
        NSRange range = self.matchWordRange;
        if (range.location != NSNotFound) {
            matchKey = [matchKey stringByAppendingString:@" "];
            NSInteger rangeIndex = range.location + range.length;
            if (rangeIndex > text.length) {
                return;
            }
            text = [text stringByReplacingCharactersInRange:range withString:matchKey];
            
            NSAttributedString *hotWordAtt = [self findHotWordAndHighLightKey:text font:self.attriFont keyworld:@""];
            if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordDidChangeAttribute:)]) {
                [self.delegate ZFOutfitSearchHotWordDidChangeAttribute:hotWordAtt];
            }
            [self endSearch];
        }
    }
}

- (void)startSearch
{
    self.isStartSearch = YES;
    self.startMatchIndex = 1;
}

- (void)endSearch
{
    self.isStartSearch = NO;
    self.startMatchIndex = 0;
}

- (NSAttributedString *)findHotWordAndHighLightKey:(NSString *)text font:(UIFont *)font keyworld:(NSString *)keyworld
{
    NSArray<NSTextCheckingResult *> *result = [ZFOutfitSearchHotWordManager queryHotWordInString:text];
    
    NSMutableAttributedString *hotWordString = [[NSMutableAttributedString alloc] initWithString:text];
    UIColor *textColor = [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
    [hotWordString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, text.length)];
    [hotWordString addAttributes:@{NSForegroundColorAttributeName : textColor} range:NSMakeRange(0, text.length)];
    
    BOOL isColor = NO;
    for (int i = 0; i < result.count; i++) {
        NSTextCheckingResult *checkingResult = result[i];
        NSString *rangString = [text substringWithRange:checkingResult.range];
//        NSString *matchString = [self matchHotWord:rangString];
//        if (!ZFIsEmptyString(rangString) && !ZFIsEmptyString(matchString)) {
        if (!ZFIsEmptyString(rangString)) {
            //加颜色
            [hotWordString addAttributes:@{NSForegroundColorAttributeName : ZFC0x3D76B9()} range:checkingResult.range];
            [hotWordString addAttributes:@{NSFontAttributeName : font} range:checkingResult.range];
            isColor = YES;
        }
    }
    
    if (!ZFIsEmptyString(keyworld)) {
        NSRange keyRange = [text rangeOfString:keyworld];
        if (keyRange.location != NSNotFound) {
             [hotWordString addAttributes:@{NSForegroundColorAttributeName : ZFC0x3D76B9()} range:keyRange];
             [hotWordString addAttributes:@{NSFontAttributeName : font} range:keyRange];
        }
    }
    
//    if (!isColor) {
//        [hotWordString addAttributes:@{NSForegroundColorAttributeName : ZFC0x3D76B9()} range:NSMakeRange(0, text.length)];
//    }
    
    return hotWordString;
}


- (NSArray *)testWordList
{
    NSArray *list = @[@"#ZZZZZ",
    @"#zaulsnap",
    @"#zafuword",
    @"#zalshow",
    @"#snap",
    @"#zlashow",
    @"#123ZZZZZ",
    @"#ZZZZZ123",
    @"#123",
    @"#321ZZZZZ",
    @"#z123aful",
    @"#111ZZZZZ",
    @"#sdz12312"];
    
    NSMutableArray *mutList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 3000; i++) {
        NSInteger random = arc4random()%list.count;
        HotWordModel *model = [HotWordModel initWithKey:[NSString stringWithFormat:@"%@%d", list[random], i] nums:i];
        [mutList addObject:model];
    }
    
//    for (int j = 0; j < 300; j++) {
//        for (int i = 0; i < list.count; i++) {
//            HotWordModel *model = [HotWordModel initWithKey:list[i] nums:i];
//            [mutList addObject:model];
//        }
//    }
    return mutList.copy;
}

@end
