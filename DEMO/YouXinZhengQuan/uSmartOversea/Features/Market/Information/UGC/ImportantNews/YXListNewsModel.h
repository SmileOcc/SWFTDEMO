//
//  YXListNewsModel.h
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2018/11/7.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXModel.h"

typedef NS_ENUM(long, YXListNewsType) {
    YXListNewsTypeSingle    =    1,
    YXListNewsTypeBig       =    2,
    YXListNewsTypeThree     =    3,
    YXListNewsTypeNo        =    4,
};

typedef NS_ENUM(long, YXRecommendType) {
    YXRecommendTypeOrdinary   =    0,
    YXRecommendTypeHot        =    1,
    YXRecommendTypeWeek       =    2,
    YXRecommendTypeTop        =    3,
};

#define YX_ListNews_IsRead @"YXListNewsIsRead"

NS_ASSUME_NONNULL_BEGIN
@interface YXListNewsStockModel : YXModel

@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, assign) NSInteger roc;
@property (nonatomic, assign) NSInteger pctchng;
// 201 场内基金  202 场外基金
@property (nonatomic, assign) NSInteger type2;
@property (nonatomic, strong) NSString *code;


@end


@interface YXListNewsJumpTagModel: YXModel;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *jump_addr;
// 0 不可调 1 h5 2 navtive
@property (nonatomic, assign) NSInteger jump_type;
@end

@interface YXListNewsUserModel: YXModel;

@property (nonatomic, assign) BOOL authUser;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, assign) int userRoleType;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *authExplain;

@end

@interface YXListNewsModel : YXModel

@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *content;// 内容
@property (nonatomic, copy) NSString *lable; //标签
@property (nonatomic, assign) NSInteger date;    //新闻时间
@property (nonatomic, copy) NSString *source;  //新闻来源
@property (nonatomic, copy) NSString *author; //作者
@property (nonatomic, strong) NSArray *feedbackArr; //反馈
@property (nonatomic, strong) NSArray *imageUrlArr; //图片
@property (nonatomic, strong) NSArray <YXListNewsStockModel *>*stockArr;   //股票数组
@property (nonatomic, copy) NSString *algorithm; //算法类型
@property (nonatomic, assign) YXRecommendType type; // 资讯类型 推荐/自选列表用
@property (nonatomic, assign) NSInteger isTop; //是否置顶 要闻首页用

@property (nonatomic, assign) CGFloat imageHegith; //图片缓存高度
@property (nonatomic, assign) CGFloat textHegith; //文字缓存高度
@property (nonatomic, assign) BOOL isRead;  //是否已读
@property (nonatomic, assign) BOOL isHideFeedback; //是否隐藏负反馈

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) NSArray <YXListNewsJumpTagModel *>*jump_tags;

/// 关联股票
@property (nonatomic, strong) NSArray <YXListNewsStockModel *>*related_stocks;
/// 关联文章
@property (nonatomic, strong) NSArray <NSString *>*related_article;

@property (nonatomic, strong) YXListNewsUserModel *user;

@property (nonatomic, assign) BOOL like_flag;
@property (nonatomic, assign) int like_count;

/// cn 中文 en 英文
@property (nonatomic, strong) NSString *language;


- (void)calculateRecommendHeight;


@end

NS_ASSUME_NONNULL_END
