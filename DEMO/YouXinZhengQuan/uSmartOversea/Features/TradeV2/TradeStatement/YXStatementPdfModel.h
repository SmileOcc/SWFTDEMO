//
//  YXStatementPdfModel.h
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXStatementPdfModel : NSObject
@property (nonatomic, strong) NSString * pdfUrl;
@property (nonatomic, copy) void(^succuessBlock)(BOOL isSuc, NSString * pdfUrl);

-(void)getsecretKey:(NSString *) pdfUrl complish:(void(^)(BOOL isSuc, NSString * pdfUrl)) block;
-(void)downLoadPdf:(NSString *)pdfUrl;
//存储到本地的名称
-(NSString *)pdfName:(NSString *) url;
//获取签名用的
-(NSString *)fileName:(NSString *) url;
-(NSString *)bucket:(NSString *) url;

-(NSString *)region:(NSString *)url;
-(NSString * )cachePdfPath:(NSString * )fileName ;
-(BOOL)isExist:(NSString *) fileName ;
-(NSData *)readPdf:(NSString *) fileName;
-(void)saveData:(NSData *) data fileName:(NSString *)fileName ;

@end

NS_ASSUME_NONNULL_END
