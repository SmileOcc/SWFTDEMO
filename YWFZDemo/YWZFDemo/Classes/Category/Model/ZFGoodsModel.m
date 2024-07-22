//
//  GoodsModel.m
//  ZZZZZ
//
//  Created by YW on 18/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsModel.h"
#import "ZFGoodsTagModel.h"
#import "ZFDBManger.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFProductCCell.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import "ZFRRPTools.h"

@interface ZFGoodsModel ()

@property (nonatomic, strong) NSAttributedString *markPriceAttributedString;

@end

@implementation ZFGoodsModel
@synthesize registerClass = _registerClass;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cat_level_column = [NSDictionary dictionary];
        self.selectedColorIndex = 0;
        self.markPriceAttributedString = nil;
    }
    return self;
}

- (void)setGoods_sn:(NSString *)goods_sn {
    _goods_sn = goods_sn;
    NSString *spuSN = @"";
    if (goods_sn.length > 7) {  // sn的前7位为同款id
        spuSN = [goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goods_sn;
    }
    _goods_spu = spuSN;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"tagsArray"        : @"tags",
             @"countDownTime"    : @"seckill_countdown",
             @"instalMentModel"  : @"instalment"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"tagsArray"        : [ZFGoodsTagModel class],
             @"groupGoodsList"   : [ZFGoodsModel class]
             };
}

/********* 数据库操作 *********/
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @autoreleasepool {
//            [self createDBTable];
//        }
//    });
//}

//2018年11月06日09:59:22 提升启动速度修改
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self createDBTable];
        }
    });
}

/// 创建数据表
+ (BOOL)createDBTable {
    BOOL isSuccess = NO;
    FMDatabase *db = [ZFDBManger shareInstance].db;
    if ([db open]) {
        NSString *goodsModelTableName   = kGoodsHistoryTableName;
        if (![[ZFDBManger shareInstance] isTableExist:goodsModelTableName]) {
            NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE '%@' ('goods_id' VARCHAR NOT NULL UNIQUE , 'wp_image' VARCHAR NOT NULL , 'goods_sn' VARCHAR, 'goods_title' VARCHAR, 'market_price' REAL NOT NULL , 'shop_price' REAL NOT NULL, 'goods_tags' BLOB, 'ID' INTEGER)", goodsModelTableName];
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                YWLog(@"error when creating db table");
                isSuccess = NO;
            } else {
                YWLog(@"success to creating db table");
                isSuccess = YES;
            }
        }
        
        // V4.4.0数据库增加3个字段 (浏览历史记录列表3Dtouch用到)
        NSArray *addColumnArr = @[@"is_on_sale", @"goods_number", @"is_collect", @"goods_spu", @"price_type"];
        for (NSString *column in addColumnArr) {
            if (![db columnExists:column inTableWithName:goodsModelTableName]){
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",goodsModelTableName, column];
                BOOL worked = [[ZFDBManger shareInstance].db executeUpdate:alertStr];
                YWLog(@"增加数据库表字段:%@===%d",column ,worked);
            }
        }
        [[ZFDBManger shareInstance].db close];
    }
    return isSuccess;
}

/// 添加数据
+ (BOOL)insertDBWithModel:(ZFGoodsModel *)goodsModel {
    NSInteger count = [self selectAllGoods].count;
    if (count >= 60) {
        [self deleteFirstModel];
    }
    
    BOOL isSuccess  = NO;
    BOOL isHaved    = [ZFGoodsModel selectDBWithGoodsID:goodsModel.goods_id].goods_id > 0 ? YES : NO;
    if (isHaved) {
        return [self updateDBWithModel:goodsModel];
    }
    
    if ([[ZFDBManger shareInstance].db open]) {
        NSData *tagsData = [NSKeyedArchiver archivedDataWithRootObject:goodsModel.tagsArray];
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
        NSTimeInterval addTime = [date timeIntervalSince1970] * 1000;
        NSInteger addTimeInt = (NSInteger)addTime;
        // 坑，二进制这能这样存储
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (goods_id, wp_image, goods_sn, goods_spu, goods_title, market_price, shop_price, goods_tags, is_on_sale, goods_number, is_collect, ID, price_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", kGoodsHistoryTableName];
        
        BOOL rs = [[ZFDBManger shareInstance].db executeUpdate:sql, goodsModel.goods_id, goodsModel.wp_image, goodsModel.goods_sn, goodsModel.goods_spu,goodsModel.goods_title, goodsModel.market_price, goodsModel.shop_price, tagsData, goodsModel.is_on_sale, goodsModel.goods_number, goodsModel.is_collect, [NSString stringWithFormat:@"%lu", addTimeInt], [NSString stringWithFormat:@"%ld", goodsModel.price_type]];
        if (!rs) {
            YWLog(@"error when insert db t_goods_history");
            isSuccess = NO;
        } else {
            YWLog(@"success to insert db t_goods_history");
            isSuccess = YES;
        }
        
        [[ZFDBManger shareInstance].db close];
    }
    return isSuccess;
}

// 更新数据
+ (BOOL)updateDBWithModel:(ZFGoodsModel *)goodsModel {
    BOOL isSuccess = NO;
    
    BOOL isHaved    = [ZFGoodsModel selectDBWithGoodsID:goodsModel.goods_id] == nil ? NO : YES;
    
    if (isHaved) {
        [self deleteDBWithGoodsID:goodsModel.goods_id];
        [self insertDBWithModel:goodsModel];
    } else {
        return [ZFGoodsModel insertDBWithModel:goodsModel];
    }
    return isSuccess;
}

// 查询单条数据
+ (ZFGoodsModel *)selectDBWithGoodsID:(NSString *)goodsID {
    ZFGoodsModel *model   = [[ZFGoodsModel alloc] init];
    if ([[ZFDBManger shareInstance].db open]) {
        NSString *sql   = [NSString stringWithFormat:@"SELECT * FROM %@ where goods_id = %@", kGoodsHistoryTableName, goodsID];
        FMResultSet *rs = [[ZFDBManger shareInstance].db executeQuery:sql];
        while ([rs next]) {
            model.goods_id     = [rs stringForColumn:@"goods_id"];
            model.goods_sn     = [rs stringForColumn:@"goods_sn"];
            model.goods_spu    = [rs stringForColumn:@"goods_spu"];
            model.wp_image     = [rs stringForColumn:@"wp_image"];
            model.goods_title  = [rs stringForColumn:@"goods_title"];
            model.market_price = [rs stringForColumn:@"market_price"];
            model.shop_price   = [rs stringForColumn:@"shop_price"];
            model.is_on_sale   = [rs stringForColumn:@"is_on_sale"];
            model.goods_number   = [rs stringForColumn:@"goods_number"];
            model.is_collect   = [rs stringForColumn:@"is_collect"];
            model.price_type = [rs intForColumn:@"price_type"];
            NSData *tagsArrayData = [rs dataForColumn:@"goods_tags"];
            NSArray *tagsArray    = [NSKeyedUnarchiver unarchiveObjectWithData:tagsArrayData];
            model.tagsArray       = tagsArray;
        }
        [[ZFDBManger shareInstance].db close];
    }
    
    return model;
}

// 删除数据
+ (BOOL)deleteDBWithGoodsID:(NSString *)goodsID {
    BOOL isSuccess = NO;
    if ([[ZFDBManger shareInstance].db open]) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where goods_id = '%@'", kGoodsHistoryTableName, goodsID];
        BOOL rs = [[ZFDBManger shareInstance].db executeUpdate:sql];
        if (!rs) {
            YWLog(@"error when DELETE db t_goods_history");
            isSuccess = NO;
        } else {
            YWLog(@"success to DELETE db t_goods_history");
            isSuccess = YES;
        }
        
        [[ZFDBManger shareInstance].db close];
    }
    return isSuccess;
}

+ (BOOL)deleteFirstModel {
    NSArray *goodsArray = [ZFGoodsModel selectAllGoods];
    ZFGoodsModel *goodsModel = goodsArray.lastObject;
    [ZFGoodsModel deleteDBWithGoodsID:goodsModel.goods_id];
    return [ZFGoodsModel deleteDBWithGoodsID:goodsModel.goods_id];
}

// 删除所有数据
+ (BOOL)deleteAllGoods {
    BOOL isSuccess = NO;
    if ([[ZFDBManger shareInstance].db open]) {
        NSString *sql   = [NSString stringWithFormat:@"DELETE FROM %@", kGoodsHistoryTableName];
        BOOL rs = [[ZFDBManger shareInstance].db executeUpdate:sql];
        if (!rs) {
            YWLog(@"error when DELETE db t_goods_history");
            isSuccess = NO;
        } else {
            YWLog(@"success to DELETE db t_goods_history");
            isSuccess = YES;
        }
        
        [[ZFDBManger shareInstance].db close];
    }
    return isSuccess;
}

// 查询所有数据
+ (void)selectAllGoods:(void(^)(NSArray<ZFGoodsModel *> *))block {
    NSMutableArray *goodsModelArray = [NSMutableArray new];

    NSString *sql   = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID DESC", kGoodsHistoryTableName];
    [[ZFDBManger shareInstance].dataBaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            ZFGoodsModel *model  = [[ZFGoodsModel alloc] init];
            model.goods_id     = [rs stringForColumn:@"goods_id"];
            model.goods_sn     = [rs stringForColumn:@"goods_sn"];
            model.goods_spu    = [rs stringForColumn:@"goods_spu"];
            model.wp_image     = [rs stringForColumn:@"wp_image"];
            model.goods_title  = [rs stringForColumn:@"goods_title"];
            model.market_price = [rs stringForColumn:@"market_price"];
            model.shop_price   = [rs stringForColumn:@"shop_price"];
            model.is_on_sale   = [rs stringForColumn:@"is_on_sale"];
            model.goods_number   = [rs stringForColumn:@"goods_number"];
            model.is_collect   = [rs stringForColumn:@"is_collect"];
            model.price_type = [rs intForColumn:@"price_type"];
            NSData *tagsArrayData = [rs dataForColumn:@"goods_tags"];
            NSArray *tagsArray    = [NSKeyedUnarchiver unarchiveObjectWithData:tagsArrayData];
            model.tagsArray       = tagsArray;
            
            [goodsModelArray addObject:model];
        }
        if (block) {
            block(goodsModelArray);
        }
    }];
}

// 同步查询所有数据
+ (NSArray<ZFGoodsModel *> *)selectAllGoods
{
    NSMutableArray *goodsModelArray = [NSMutableArray new];
    
    if ([[ZFDBManger shareInstance].db open]) {
        NSString *sql   = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID DESC", kGoodsHistoryTableName];
        FMResultSet *rs = [[ZFDBManger shareInstance].db executeQuery:sql];
        while ([rs next]) {
            ZFGoodsModel *model  = [[ZFGoodsModel alloc] init];
            model.goods_id     = [rs stringForColumn:@"goods_id"];
            model.goods_sn     = [rs stringForColumn:@"goods_sn"];
            model.goods_spu    = [rs stringForColumn:@"goods_spu"];
            model.wp_image     = [rs stringForColumn:@"wp_image"];
            model.goods_title  = [rs stringForColumn:@"goods_title"];
            model.market_price = [rs stringForColumn:@"market_price"];
            model.shop_price   = [rs stringForColumn:@"shop_price"];
            model.is_on_sale   = [rs stringForColumn:@"is_on_sale"];
            model.goods_number   = [rs stringForColumn:@"goods_number"];
            model.is_collect   = [rs stringForColumn:@"is_collect"];
            model.price_type = [rs intForColumn:@"price_type"];
            NSData *tagsArrayData = [rs dataForColumn:@"goods_tags"];
            NSArray *tagsArray    = [NSKeyedUnarchiver unarchiveObjectWithData:tagsArrayData];
            model.tagsArray       = tagsArray;

            [goodsModelArray addObject:model];
        }
        [[ZFDBManger shareInstance].db close];
    }
    
    return goodsModelArray;
}

- (void)setMarket_price:(NSString *)market_price
{
    _market_price = market_price;
    if (!self.markPriceAttributedString) {
        if (ZFToString(_market_price).length) {
            NSString *marketPrice = [ExchangeManager transforPrice:_market_price];
            self.markPriceAttributedString = [[NSMutableAttributedString alloc] initWithString:marketPrice attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
        }
    }
}

- (NSAttributedString *)gainMarkPriceAttributedString
{
    return self.markPriceAttributedString;
}

- (BOOL)handleRRPPrice
{
    if (!_RRPAttributedPriceString) {
        NSString *marketPrice = @"";
        if (!self.isHideMarketPrice) {
            marketPrice = self.market_price;
        }
        ZFRRPModel *rrpModel = [ZFRRPTools gainZFRRPAttributedString:self.shop_price marketPrice:marketPrice];
        _RRPAttributedPriceString = rrpModel.rrpString;
        _priceNeedWrapLine = rrpModel.needWarp;
        return _priceNeedWrapLine;
    }
    return _priceNeedWrapLine;
}

- (NSAttributedString *)RRPAttributedPriceString
{
    if (!_RRPAttributedPriceString) {
        [self handleRRPPrice];
    }
    return _RRPAttributedPriceString;
}

- (void)setPrice_type:(NSInteger)price_type
{
    _price_type = price_type;
}

- (BOOL)showMarketPrice
{
    if (self.price_type == 1 || self.price_type == 2 || self.price_type == 3 || self.price_type == 4 || self.price_type == 5) {
        return YES;
    }
    return NO;
}

#pragma mark - tracking

- (NSDictionary *)gainAnalyticsParams
{
    NSString *skuSN = nil;
    if (self.goods_sn.length > 7) {
        skuSN = [self.goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        skuSN = self.goods_sn;
    }
    NSDictionary *params = @{
                             @"goodsName_var" : self.goods_title,  //商品名称
                             @"SKU_var" : self.goods_sn,           //SKU id
                             @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
                             @"firstCat_var" : ZFToString(self.cat_level_column[@"first_cat_name"]),       //一级分类
                             @"sndCat_var" : ZFToString(self.cat_level_column[@"snd_cat_name"]),           //二级分类
                             @"thirdCat_var" : ZFToString(self.cat_level_column[@"third_cat_name"]),       //三级分类
                             @"forthCat_var" : ZFToString(self.cat_level_column[@"forth_cat_name"]),       //四级分类
                             @"storageNum_var" : ZFToString(self.goods_number),                            //库存数量
                             @"marketType_var" : ZFToString(self.channel_type),                            //营销类型
                             };
    return params;
}

#pragma mark - model protocol

- (NSString *)CollectionDatasourceCell:(NSIndexPath *)indexPath identifier:(id)identifier
{
    return NSStringFromClass([ZFProductCCell class]);
}

- (Class)registerClass
{
    return [ZFProductCCell class];
}

@end
