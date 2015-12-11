//
//  DatabaseTool.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/24.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatabaseTool : UIViewController
/**
 *  单例对象
 */
+ (id)shared;

/**
 *  将获取的会员数据存入到数据库
 */
- (BOOL)insertInitMembers:(NSArray *)members;

/**
 *  清空数据库
 */
- (BOOL)emptyDataBase;

/**
 *  取出默认的成员
 */
- (NSMutableDictionary *)getDefaultMember;
/**
 *  取出全部的成员
 */
- (NSMutableArray *)getAllMembers;

/**
 *  设置为选中的成员
 */
- (BOOL)DefaultMemberWithAcc_id:(NSString *)acc_id Mid:(NSString *)mid;

/**
 *  获取默认成员的温度记录
 */
- (NSMutableArray *)getDefaultMemberDiaryInfoArray;

/**
 *  添加一个温度记录到数据库
 */
- (BOOL)addDiary:(NSMutableDictionary *)diary;

/**
 *  删除一个成员
 */
- (BOOL)removeOneMember:(NSString *)mid;

/**
 *  获取默认成员的最新一条温度记录
 */
- (NSMutableDictionary *)getDefaultMemberLastDiary;

/**
 *  添加一个成员
 */
- (BOOL)addMember:(NSDictionary *)member;

/**
 *  修改一个成员
 */
- (BOOL)updateMember:(NSDictionary *)member;
/**
 *  删除一条记录
 */
- (BOOL)removeDiaryByDiaryId:(NSString *)diaryId;
/**
 *  更新一个病历温度记录到数据库
 */
- (BOOL)updateDiary:(NSMutableDictionary *)diary;
/**
 *  添加温度记录数组
 */
- (BOOL)addDiaryWithArray:(NSArray *)array;
/**
 *  获取温度记录数据
 */
- (NSMutableArray *)getDefaultMemberDiaryFromPage:(int)page;
@end
