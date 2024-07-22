//
//  ZFGoodsDetailGroupBuyModel.h
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


//// 开团模型
//@interface ZFGroupBuyStartTeamModel : NSObject
//
///// 开团的code
//@property (nonatomic, assign) NSInteger team_code;
///// 分享code
//@property (nonatomic, assign) NSInteger share_code;
//
//@property (nonatomic, copy) NSString *is_have_open;
//@end



@interface ZFGroupBuyMemberModel : NSObject

/// 是否是团长
@property (nonatomic, assign) NSInteger is_leader;
/// 是否中奖
@property (nonatomic, assign) NSInteger is_win;
/// 参团用户昵称
@property (nonatomic, copy) NSString *nick_name;
/// 参团用户头像
@property (nonatomic, copy) NSString *avatar;
@end


@interface ZFGroupBuyTeamModel : NSObject
/// 是否参团了：0否 1是，当用户登录时才有此字段
@property (nonatomic, assign) NSInteger is_have_join;
/// 还差多少人成团
@property (nonatomic, assign) NSInteger left_nums;
///
@property (nonatomic, copy) NSString *act_code;
///
@property (nonatomic, copy) NSString *use_app_guide;
///
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, copy) NSString *share_title;
@property (nonatomic, copy) NSString *share_content;
/// 成团剩余时间，秒
@property (nonatomic, copy) NSString *left_time;

/// 成团倒计时秒数key
@property (nonatomic, copy) NSString *countDownTimerKey;


/// 是否是团长 0否 1是
@property (nonatomic, assign) NSInteger is_leader;
/// 团状态:成团状态 0待成团 1成团成功 2成团失败
@property (nonatomic, copy) NSString *team_status;
/// 参团人员信息，包括开团
@property (nonatomic, strong) NSArray<ZFGroupBuyMemberModel *> *team_members;
@end


@interface ZFGoodsDetailGroupBuyModel : NSObject

/// 1 表示商品拼团 0 不是
@property (nonatomic, assign) NSInteger status;
/// 拼团的价格
@property (nonatomic, copy) NSString *price;
/// 拼团提醒
@property (nonatomic, copy) NSString *price_msg;
/// 开团提示
@property (nonatomic, copy) NSString *join_msg;
/// 需要的人数
@property (nonatomic, copy) NSString *need_num;
/// 活动code
@property (nonatomic, copy) NSString *act_code;
/// 1 可以开团, 0 不可以开团
@property (nonatomic, assign) NSInteger can_start;
/// 首次开团成功
@property (nonatomic, assign) BOOL isFirstStart;
/** 我的团H5地址 */
@property (nonatomic, strong) NSString *team_detail_url;

@property (nonatomic, strong) ZFGroupBuyTeamModel *team_detail;

/** V4.5.6商详的H5拼团入口地址 */
@property (nonatomic, strong) NSString *jump_url;
/** V4.5.6商详的H5拼团入口页面标题 */
@property (nonatomic, copy) NSString *title;


@end

NS_ASSUME_NONNULL_END
