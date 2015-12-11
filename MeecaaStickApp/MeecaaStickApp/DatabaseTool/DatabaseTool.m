//
//  DatabaseTool.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/24.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "DatabaseTool.h"
#import "FMDB.h"

#define PAGENUMBER @"10"
@interface DatabaseTool ()

@end

@implementation DatabaseTool
/**
 *  单例对象
 */
+ (id)shared {
    static DatabaseTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

/**
 *  初始化方法
 */
- (id)init {
    self = [super init];
    return self;
}

/**
 *  将获取的会员数据存入到数据库
 */
- (BOOL)insertInitMembers:(NSArray *)members
{
    //预先判断有没有这个数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"打开数据库失败!");
        [db close];
        return NO;
    } else {
        //建立数据库
        BOOL isCreateTable = [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!isCreateTable) {
            NSLog(@"创建数据表失败!");
            return NO;
        }
        BOOL isDeleteTable = [db executeUpdate:@"delete from t_member;"];
        if (!isDeleteTable) {
            NSLog(@"清除数据失败!");
            return NO;
        }
        for (NSDictionary *member in members) {
            NSString *acc_id = [NSString stringWithFormat:@"%@",member[@"acc_id"]];
            NSString *addr = member[@"addr"];
            NSString *avatar = member[@"avatar"];
            NSString *birth = member[@"birth"];
            NSString *city = member[@"city"];
            NSString *mid = [NSString stringWithFormat:@"%@",member[@"id"]];
            NSString *isdefault = [NSString stringWithFormat:@"%@",member[@"isdefault"]];
            NSString *name = member[@"name"];
            NSString *sex = [NSString stringWithFormat:@"%@",member[@"sex"]];
            BOOL result = [db executeUpdate:@"insert into t_member (acc_id,addr,avatar,birth,city,id,isdefault,name,sex) values (?,?,?,?,?,?,?,?,?);",acc_id,addr,avatar,birth,city,mid,isdefault,name,sex];
            if (!result) {
                [db close];
                return NO;
            }
        }
        [db close];
        return YES;
    }
}

/**
 *  清空数据库
 */
- (BOOL)emptyDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
        if (!isRemove) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

/**
 *  取出默认的成员
 */
- (NSMutableDictionary *)getDefaultMember
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableDictionary *memberInfoDict = [NSMutableDictionary dictionary];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return nil;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        FMResultSet *set = [db executeQuery:@"select * from t_member where isdefault='1';"];
        if ([set next]) {
            memberInfoDict[@"acc_id"] = [set stringForColumn:@"acc_id"];
            memberInfoDict[@"addr"] = [set stringForColumn:@"addr"];
            memberInfoDict[@"avatar"] = [set stringForColumn:@"avatar"];
            memberInfoDict[@"birth"] = [set stringForColumn:@"birth"];
            memberInfoDict[@"city"] = [set stringForColumn:@"city"];
            memberInfoDict[@"id"] = [set stringForColumn:@"id"];
            memberInfoDict[@"isdefault"] = [set stringForColumn:@"isdefault"];
            memberInfoDict[@"name"] = [set stringForColumn:@"name"];
            memberInfoDict[@"sex"] = [set stringForColumn:@"sex"];
        } else {
            [db close];
            return nil;
        }
        [db close];
        return memberInfoDict;
    }
}
/**
 *  取出全部的成员
 */
- (NSMutableArray *)getAllMembers{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *members = [NSMutableArray array];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return nil;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        FMResultSet *set = [db executeQuery:@"select * from t_member;"];
        while([set next]) {
            NSMutableDictionary *memberInfoDict = [NSMutableDictionary dictionary];
            memberInfoDict[@"acc_id"] = [set stringForColumn:@"acc_id"];
            memberInfoDict[@"addr"] = [set stringForColumn:@"addr"];
            memberInfoDict[@"avatar"] = [set stringForColumn:@"avatar"];
            memberInfoDict[@"birth"] = [set stringForColumn:@"birth"];
            memberInfoDict[@"city"] = [set stringForColumn:@"city"];
            memberInfoDict[@"id"] = [set stringForColumn:@"id"];
            memberInfoDict[@"isdefault"] = [set stringForColumn:@"isdefault"];
            memberInfoDict[@"name"] = [set stringForColumn:@"name"];
            memberInfoDict[@"sex"] = [set stringForColumn:@"sex"];
            [members addObject:memberInfoDict];
        }
        [db close];
        return members;
    }
}
/**
 *  设置为选中的成员
 */
- (BOOL)DefaultMemberWithAcc_id:(NSString *)acc_id Mid:(NSString *)mid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '');"];
        BOOL result = [db executeUpdate:@"update t_member set isdefault='0';"];
        if (!result) {
            [db close];
            return NO;
        } else {
            BOOL rs = [db executeUpdate:@"update t_member set isdefault='1' where acc_id=? and id=?",acc_id,mid];
            if (rs) {
                [db close];
                return YES;
            } else {
                [db close];
                return NO;
            }
        }
    }
}

/**
 *  获取默认成员的温度记录
 */
- (NSMutableArray *)getDefaultMemberDiaryInfoArray
{
    NSDictionary *defaultMember = [self getDefaultMember];
    NSString *member_id = [NSString stringWithFormat:@"%@",defaultMember[@"id"]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *resultArray = [NSMutableArray array];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return nil;
    } else {
        BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!createTable) {
            NSLog(@"创建数据库失败!");
            [db close];
            return nil;
        }
        FMResultSet *set = [db executeQuery:@"select * from t_diary where member_id=? order by date desc;",member_id];
        while ([set next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"date"] = [set stringForColumn:@"date"];
            dict[@"description"] = [set stringForColumn:@"description"];
            dict[@"id"] = [set stringForColumn:@"id"];
            dict[@"longitude"] = [set stringForColumn:@"longitude"];
            dict[@"latitude"] = [set stringForColumn:@"latitude"];
            dict[@"member_id"] = [set stringForColumn:@"member_id"];
            dict[@"photo_count"] = [set stringForColumn:@"photo_count"];
            dict[@"symptoms"] = [set stringForColumn:@"symptoms"];
            dict[@"temperature"] = [set stringForColumn:@"temperature"];
            NSString *picsStr = [set stringForColumn:@"pics"];
            NSArray *picsArray = [picsStr componentsSeparatedByString:@","];
            dict[@"pics"] = picsArray;
            [resultArray addObject:dict];
        }
    }
    [db close];
    if (resultArray.count == 0) {
        return nil;
    } else {
        return resultArray;
    }
}

/**
 *  添加一个温度记录到数据库
 */
- (BOOL)addDiary:(NSMutableDictionary *)diary
{
    NSMutableArray *tempPics = [diary objectForKey:@"pics"];
    NSString *picsStr = @"";
    if (tempPics.count > 0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSMutableDictionary *picDict in tempPics) {
            NSString *picUrl = picDict[@"img"];
            [tempArray addObject:picUrl];
        }
        NSMutableArray *pics = tempArray;
        picsStr = [pics componentsJoinedByString:@","];
    } else {
        picsStr = @"";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!createTable) {
            NSLog(@"创建数据库失败!");
            [db close];
            return NO;
        } else {
            NSString *date = [NSString stringWithFormat:@"%@",diary[@"date"]];
            NSString *description = [NSString stringWithFormat:@"%@",diary[@"description"]];
            NSString *diaryId = [NSString stringWithFormat:@"%@",diary[@"id"]];
            NSString *longitude = [NSString stringWithFormat:@"%@",diary[@"longitude"]];
            NSString *latitude = [NSString stringWithFormat:@"%@",diary[@"latitude"]];
            NSString *member_id = [NSString stringWithFormat:@"%@",diary[@"member_id"]];
            NSString *photo_count = [NSString stringWithFormat:@"%@",diary[@"photo_count"]];
            NSString *symptoms = [NSString stringWithFormat:@"%@",diary[@"symptoms"]];
            NSString *temperature = [NSString stringWithFormat:@"%@",diary[@"temperature"]];
            BOOL result = [db executeUpdate:@"insert into t_diary (date,description,id,longitude,latitude,member_id,photo_count,symptoms,temperature,pics) values (?,?,?,?,?,?,?,?,?,?);",date,description,diaryId,longitude,latitude,member_id,photo_count,symptoms,temperature,picsStr];
            if (!result) {
                NSLog(@"插入数据失败!");
                [db close];
                return NO;
            } else {
                [db close];
                return YES;
            }
        }
    }
}


/**
 *  删除一个成员
 */
- (BOOL)removeOneMember:(NSString *)mid{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '');"];
        BOOL result = [db executeUpdate:@"delete from t_member where id=?",mid];
        if (!result) {
            [db close];
            return NO;
        } else {
            [db close];
            return YES;
        }
    }

}

/**
 *  获取默认成员的最新一条温度记录
 */
- (NSMutableDictionary *)getDefaultMemberLastDiary
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return nil;
    } else {
        BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!createTable) {
            NSLog(@"创建数据库失败!");
            [db close];
            return nil;
        } else {
            //获取默认成员的ID
            NSDictionary *defaultMember = [self getDefaultMember];
            NSString *member_id = [NSString stringWithFormat:@"%@",defaultMember[@"id"]];
            NSMutableDictionary *diaryInfo = [NSMutableDictionary dictionary];
            FMResultSet *set = [db executeQuery:@"select * from t_diary where member_id=? order by id desc limit 1;",member_id];
            if([set next]) {
                diaryInfo[@"date"] = [set stringForColumn:@"date"];
                diaryInfo[@"description"] = [set stringForColumn:@"description"];
                diaryInfo[@"id"] = [set stringForColumn:@"id"];
                diaryInfo[@"longitude"] = [set stringForColumn:@"longitude"];
                diaryInfo[@"latitude"] = [set stringForColumn:@"latitude"];
                diaryInfo[@"member_id"] = [set stringForColumn:@"member_id"];
                diaryInfo[@"photo_count"] = [set stringForColumn:@"photo_count"];
                diaryInfo[@"symptoms"] = [set stringForColumn:@"symptoms"];
                diaryInfo[@"temperature"] = [set stringForColumn:@"temperature"];
                diaryInfo[@"pics"] = [set stringForColumn:@"pics"];
                [db close];
                return diaryInfo;
            } else {
                [db close];
                return nil;
            }
        }
    }
}

/**
 *  添加一个成员
 */
- (BOOL)addMember:(NSDictionary *)member
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '');"];
        NSString *acc_id = [NSString stringWithFormat:@"%@",member[@"acc_id"]];
        NSString *addr = member[@"addr"];
        NSString *avatar = member[@"avatar"];
        NSString *birth = member[@"birth"];
        NSString *city = member[@"city"];
        NSString *mid = [NSString stringWithFormat:@"%@",member[@"id"]];
        NSString *isdefault = [NSString stringWithFormat:@"%@",member[@"isdefault"]];
        NSString *name = member[@"name"];
        NSString *sex = [NSString stringWithFormat:@"%@",member[@"sex"]];
        BOOL result = [db executeUpdate:@"insert into t_member (acc_id,addr,avatar,birth,city,id,isdefault,name,sex) values (?,?,?,?,?,?,?,?,?);",acc_id,addr,avatar,birth,city,mid,isdefault,name,sex];
        if (!result) {
            [db close];
            return NO;
        } else {
            [db close];
            return YES;
        }
    }
}
/**
 *  修改一个成员
 */
- (BOOL)updateMember:(NSDictionary *)member
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        //建立数据库
        [db executeUpdate:@"create table if not exists t_member (acc_id text not null default '',addr text not null default '',avatar text not null default '',birth text not null default '',city text not null default '',id text default '',isdefault text not null default '',name text not null default '',sex text not null default '');"];
        NSString *mid = [NSString stringWithFormat:@"%@",member[@"id"]];
        NSString *name = member[@"name"];
        NSString *sex = [NSString stringWithFormat:@"%@",member[@"sex"]];
        NSString *birth = member[@"birth"];
        NSString *city = member[@"city"];
        NSString *avatar = member[@"avatar"];
        
        BOOL result = [db executeUpdate:@"update t_member set name=?,sex=?,birth=?,city=?,avatar=? where id=?;",name,sex,birth,city,avatar,mid];
        if (!result) {
            [db close];
            return NO;
        } else {
            [db close];
            return YES;
        }
    }
}

/**
 *  删除一条记录
 */
- (BOOL)removeDiaryByDiaryId:(NSString *)diaryId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        BOOL result = [db executeUpdate:@"delete from t_diary where id=?",diaryId];
        if (!result) {
            [db close];
            return NO;
        } else {
            [db close];
            return YES;
        }
    }
    return YES;
}

/**
 *  更新一个病历温度记录到数据库
 */
- (BOOL)updateDiary:(NSMutableDictionary *)diary{
    NSMutableArray *tempPics = [diary objectForKey:@"pics"];
    NSString *picsStr = @"";
    if (tempPics.count > 0) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSMutableDictionary *picDict in tempPics) {
            NSString *picUrl = picDict[@"img"];
            [tempArray addObject:picUrl];
        }
        NSMutableArray *pics = tempArray;
        picsStr = [pics componentsJoinedByString:@","];
    } else {
        picsStr = @"";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!createTable) {
            NSLog(@"创建数据库失败!");
            [db close];
            return NO;
        } else {
            NSString *diaryId = [NSString stringWithFormat:@"%@",diary[@"id"]];
            NSString *temperature = [NSString stringWithFormat:@"%@",diary[@"temperature"]];
            NSString *date = [NSString stringWithFormat:@"%@",diary[@"date"]];
            NSString *symptoms = [NSString stringWithFormat:@"%@",diary[@"symptoms"]];
            NSString *photo_count = [NSString stringWithFormat:@"%@",diary[@"photo_count"]];
            NSString *description = [NSString stringWithFormat:@"%@",diary[@"description"]];
            BOOL result = [db executeUpdate:@"update t_diary set temperature=?,date=?,symptoms=?,photo_count=?,description=? where id=?",temperature,date,symptoms,photo_count,description,diaryId];
            if (!result) {
                NSLog(@"插入数据失败!");
                [db close];
                return NO;
            } else {
                [db close];
                return YES;
            }
        }
    }
}

/**
 *  添加温度记录数组
 */
- (BOOL)addDiaryWithArray:(NSArray *)array {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return NO;
    } else {
        for (NSMutableDictionary *diary in array) {
            NSMutableArray *tempPics = [diary objectForKey:@"pics"];
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSMutableDictionary *picDict in tempPics) {
                NSString *picUrl = picDict[@"img"];
                [tempArray addObject:picUrl];
            }
            NSMutableArray *pics = tempArray;
            NSString *picsStr = [pics componentsJoinedByString:@","];
            BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
            if (!createTable) {
                NSLog(@"创建数据库失败!");
                [db close];
                return NO;
            } else {
                NSString *date = [NSString stringWithFormat:@"%@",diary[@"date"]];
                NSString *description = [NSString stringWithFormat:@"%@",diary[@"description"]];
                NSString *diaryId = [NSString stringWithFormat:@"%@",diary[@"id"]];
                NSString *longitude = [NSString stringWithFormat:@"%@",diary[@"longitude"]];
                NSString *latitude = [NSString stringWithFormat:@"%@",diary[@"latitude"]];
                NSString *member_id = [NSString stringWithFormat:@"%@",diary[@"member_id"]];
                NSString *photo_count = [NSString stringWithFormat:@"%@",diary[@"photo_count"]];
                NSString *symptoms = [NSString stringWithFormat:@"%@",diary[@"symptoms"]];
                NSString *temperature = [NSString stringWithFormat:@"%@",diary[@"temperature"]];
                BOOL result = [db executeUpdate:@"insert into t_diary (date,description,id,longitude,latitude,member_id,photo_count,symptoms,temperature,pics) values (?,?,?,?,?,?,?,?,?,?);",date,description,diaryId,longitude,latitude,member_id,photo_count,symptoms,temperature,picsStr];
                if (!result) {
                    NSLog(@"插入数据失败!");
                    [db close];
                    return NO;
                }
            }
        }
        [db close];
        return YES;
    }
}

/**
 *  获取温度记录数据
 */
- (NSMutableArray *)getDefaultMemberDiaryFromPage:(int)page {
    NSDictionary *defaultMember = [[DatabaseTool shared] getDefaultMember];
    NSString *member_id = [NSString stringWithFormat:@"%@",defaultMember[@"id"]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    NSString *dbPath = [path stringByAppendingPathComponent:@"meecaa.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *resultArray = [NSMutableArray array];
    if (![db open]) {
        NSLog(@"数据库未打开!");
        [db close];
        return nil;
    } else {
        BOOL createTable = [db executeUpdate:@"create table if not exists t_diary (date text not null default '',description text not null default '',id text not null default '',latitude text not null default '',longitude text not null default '',member_id text not null default '',photo_count text not null default '',symptoms text not null default '',temperature text not null default '',pics text not null default '',col0 text not null default '',col1 text not null default '',col2 text not null default '',col3 text not null default '',col4 text not null default '');"];
        if (!createTable) {
            NSLog(@"创建数据库失败!");
            [db close];
            return nil;
        }
        NSString *pageStr = [NSString stringWithFormat:@"%d",(page-1) * [PAGENUMBER intValue]];
        FMResultSet *set = [db executeQuery:@"select * from t_diary where member_id=? order by date desc limit ?,?;",member_id,pageStr,PAGENUMBER];
        while ([set next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"date"] = [set stringForColumn:@"date"];
            dict[@"description"] = [set stringForColumn:@"description"];
            dict[@"id"] = [set stringForColumn:@"id"];
            dict[@"longitude"] = [set stringForColumn:@"longitude"];
            dict[@"latitude"] = [set stringForColumn:@"latitude"];
            dict[@"member_id"] = [set stringForColumn:@"member_id"];
            dict[@"photo_count"] = [set stringForColumn:@"photo_count"];
            dict[@"symptoms"] = [set stringForColumn:@"symptoms"];
            dict[@"temperature"] = [set stringForColumn:@"temperature"];
            NSString *picsStr = [set stringForColumn:@"pics"];
            NSArray *picsArray = [picsStr componentsSeparatedByString:@","];
            dict[@"pics"] = picsArray;
            [resultArray addObject:dict];
        }
    }
    [db close];
    return resultArray;
}

@end
