//
//  fingerprinting.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/17.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "fingerprinting.h"
#import "rssi_data.h"

@interface DataBaseHandle ()

@property (nonatomic , copy)NSString * dataBaseName ;

@end

@implementation DataBaseHandle

static sqlite3 * db ;

+(instancetype)dataBaseHandleWithDataBaseName:(NSString *)dataBaseName
{
    DataBaseHandle * dataBaseHandle = [[self alloc] init];
    dataBaseHandle.dataBaseName = dataBaseName ;
    
    NSString * dataBaseFile = [dataBaseHandle dataBaseFile];
    
    // Open database
    int result = sqlite3_open([dataBaseFile UTF8String], &db);
    
    if (result == SQLITE_OK) {
        //autoincrement used for primary key (number);
        NSString * sqliteStr = @"create table if not exists RssiList(number integer primary key autoincrement, x double, y double, beacon integer, value integer)";
        // execute command
        sqlite3_exec(db, [sqliteStr UTF8String], NULL, NULL, NULL);
    }
    
    return dataBaseHandle ;
}

// Path to database Caches folder
-(NSString *)dataBasePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

// Path to database file
-(NSString *)dataBaseFile
{
    return [[self dataBasePath] stringByAppendingPathComponent:[self.dataBaseName stringByAppendingString:@".db"]];
}

// Open database
-(void)openDataBase
{
    NSString * dataBaseFile = [self dataBaseFile];
    //NSLog(@"%@",dataBaseFile);
    int result = sqlite3_open([dataBaseFile UTF8String], &db);
    
    if (result == SQLITE_OK) {
        //NSLog(@"Database opened!");
    }
    else{
        NSLog(@"Database failed!");
    }
}

// Close database
-(void)closeDataBase
{
    sqlite3_close(db);
    //NSLog(@"%@",result == SQLITE_OK ? @"Closed successfully":@"Closed unsuccessfully");
}

// Insert data
-(void)insertDataWithKeyValues:(RssiEntity *)entity
{
    [self openDataBase];
    
    // sql command
    NSString * sqlStr = @"insert into RssiList(number,x,y,beacon,value)values(?,?,?,?,?)";
    
    // create data manager pointer
    sqlite3_stmt * stmt = nil ;
    
    // verify command
    int result = sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &stmt, NULL);

    if (result == SQLITE_OK) {
        NSLog(@"Inserted data");
        // Bind data
        sqlite3_bind_int(stmt, 1, (int)entity.number);
        sqlite3_bind_double(stmt, 2, (double)entity.x);
        sqlite3_bind_double(stmt, 3, (double)entity.y);
        sqlite3_bind_int(stmt, 4, (int)entity.beacon);
        sqlite3_bind_int(stmt, 5, (int)entity.value);

        // execute sql command
        sqlite3_step(stmt);
    }
    
    // release pointer
    sqlite3_finalize(stmt);
    
    // close database
    [self closeDataBase];
}

// Update data by x and y
-(void)updateRssi:(NSInteger)rssi x_value:(double)x_value y_value:(double)y_value
{
    [self openDataBase];

    sqlite3_stmt * stmt = nil ;

    NSString * sql = @"update RssiList set value = ? where x = ? and y = ?";

    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);

    if (result == SQLITE_OK) {

        sqlite3_bind_int(stmt, 1, (int)rssi);
        sqlite3_bind_double(stmt, 2, (double)x_value);
        sqlite3_bind_double(stmt, 3, (double)y_value);

        sqlite3_step(stmt);
    }

    sqlite3_finalize(stmt);
    [self closeDataBase];
}

// Select all data
-(NSArray<RssiEntity *> *)selectAllKeyValues
{
    [self openDataBase];
    NSString * sql = @"select * from RssiList ";
    sqlite3_stmt * stmt = nil ;
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
    
    NSMutableArray * mArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (result == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            RssiEntity * entity = [[RssiEntity alloc] init];
            [mArr addObject:entity];
            
            entity.number = sqlite3_column_int(stmt, 0);
            entity.x = sqlite3_column_double(stmt, 1);
            entity.y = sqlite3_column_double(stmt, 2);
            entity.beacon = sqlite3_column_int(stmt, 3);
            entity.value = sqlite3_column_int(stmt, 4);
            NSLog(@"%.1f",entity.x);
        }
    }
    sqlite3_finalize(stmt);
    [self closeDataBase];
    
    return mArr ;
}

// Select data by number
-(RssiEntity *)selectOneByNumber:(NSInteger)number
{
    [self openDataBase];
    NSString * sql = @"select * from RssiList where number = ?";
    // @"select * from RssiList where number > ? limit 5" only select first 5 elements
    // @"select * from RssiList where number > ? limit 3,5" ignore the first 3 elements and then select5 elements
    // @"select * from RssiList where number > ?  order by stu_age disc " Ordered by desc
    // @"select x,y from RssiList where ...... " Select x and y values
    
    sqlite3_stmt * stmt = nil ;
    RssiEntity * entity = [[RssiEntity alloc] init];

    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, (int)number);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            entity.number = sqlite3_column_int(stmt, 0);
            entity.x = sqlite3_column_double(stmt, 1);
            entity.y = sqlite3_column_double(stmt, 2);
            entity.beacon = sqlite3_column_int(stmt, 3);
            entity.value = sqlite3_column_int(stmt, 4);
        }
    }
    sqlite3_finalize(stmt);
    [self closeDataBase];
    
    return entity;
}

// Select data by beacon and rssi value
-(NSMutableArray *)selectOneByrssi:(NSInteger)beacon value:(NSInteger)value
{
    NSMutableArray * xy_array = [[NSMutableArray alloc] init];;
    [self openDataBase];
    NSString * sql = @"select * from RssiList where beacon = ? and value >= ? and value <= ?";
    // @"select * from RssiList where number > ? limit 5" only select first 5 elements
    // @"select * from RssiList where number > ? limit 3,5" ignore the first 3 elements and then select5 elements
    // @"select * from RssiList where number > ?  order by stu_age disc " Ordered by desc
    // @"select x,y from RssiList where ...... " Select x and y values
    
    sqlite3_stmt * stmt = nil ;
    RssiEntity * entity = [[RssiEntity alloc] init];
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, (int)beacon);
        sqlite3_bind_int(stmt, 2, (int)(value-1));
        sqlite3_bind_int(stmt, 3, (int)(value+1));
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            entity.x = sqlite3_column_double(stmt, 1);
            entity.y = sqlite3_column_double(stmt, 2);
            NSString * xy_value = [NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%.1f", (double)entity.x],[NSString stringWithFormat:@"%.1f", (double)entity.y]];
            [xy_array addObject:xy_value];
        }
    }

    sqlite3_finalize(stmt);
    [self closeDataBase];
    return xy_array;
}

// Delete data by x and y
-(void)deleteOneRssi:(NSInteger)x_value y_value:(NSInteger)y_value
{
    [self openDataBase];

    NSString * sql = @"delete from RssiList where x = ? and y = ?";

    sqlite3_stmt * stmt = nil ;

    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);

    if (result == SQLITE_OK) {

        sqlite3_bind_double(stmt, 1, (double)x_value);
        sqlite3_bind_double(stmt, 2, (double)y_value);

        // execute command
        sqlite3_step(stmt);
    }

    sqlite3_finalize(stmt);
    [self closeDataBase];
}

// Delete the table
-(void)dropTable
{
    [self openDataBase];
    
    NSString * sql = @"drop table RssiList";
    
    sqlite3_stmt * stmt = nil ;
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        NSLog(@"Successfully drop table");
        sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    [self closeDataBase];
}


@end
