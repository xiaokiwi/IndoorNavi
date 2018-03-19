//
//  fingerprinting.h
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/17.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RssiEntity ;

@interface DataBaseHandle : NSObject

+(instancetype)dataBaseHandleWithDataBaseName:(NSString *)dataBaseName;

// Open database
-(void)openDataBase ;

// Close database
-(void)closeDataBase ;

// Insert data
-(void)insertDataWithKeyValues:(RssiEntity *)entity ;

// Update
-(void)updateRssi:(NSInteger)rssi x_value:(NSInteger)x_value y_value:(NSInteger)y_value;

// Find all data
-(NSArray<RssiEntity *> *)selectAllKeyValues ;

// Select data by number
-(RssiEntity *)selectOneByNumber:(NSInteger)number ;

// delete data by x and y
-(void)deleteOneRssi:(NSInteger)x_value y_value:(NSInteger)y_value;

// delete table
-(void)dropTable;


@end