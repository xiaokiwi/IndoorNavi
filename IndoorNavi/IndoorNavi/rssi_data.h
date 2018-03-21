//
//  rssi_data.h
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/17.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RssiEntity : NSObject

@property(nonatomic,assign)NSInteger number;
@property(nonatomic,assign)double x;
@property(nonatomic,assign)double y;
@property(nonatomic,assign)NSInteger beacon;
@property(nonatomic,assign)NSInteger value;

@end
