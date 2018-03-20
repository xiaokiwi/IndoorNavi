//
//  ViewController.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import "TriangulationAlgorithm.h"
#include <math.h>
#import "fingerprinting.h"
#import "rssi_data.h"


@interface ViewController () {
    NSMutableArray *peripheralDataArray;
    BabyBluetooth *baby;
    TriangulationCalculator * triangulationCalculator;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Database Setup
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"RssiDB"];

    // Insert Data (examples)
    RssiEntity * entity = [[RssiEntity alloc] init];
    entity.number = 1 ;
    entity.x = 100;
    entity.y = 321;
    entity.beacon = 1;
    entity.value = -65;

    RssiEntity * entity2 = [[RssiEntity alloc] init];
    entity2.number = 2 ;
    entity2.x = 100;
    entity2.y = 321;
    entity2.beacon = 2;
    entity2.value = -67;
    
    RssiEntity * entity3 = [[RssiEntity alloc] init];
    entity3.number = 3 ;
    entity3.x = 14;
    entity3.y = 41;
    entity3.beacon = 3;
    entity3.value = -66;

    RssiEntity * entity4 = [[RssiEntity alloc] init];
    entity4.number = 4 ;
    entity4.x = 133;
    entity4.y = 111;
    entity4.beacon = 2;
    entity4.value = -67;
    
    RssiEntity * entity5 = [[RssiEntity alloc] init];
    entity5.number = 5 ;
    entity5.x = 13;
    entity5.y = 11;
    entity5.beacon = 2;
    entity5.value = -68;
    
    [dataBaseHandle insertDataWithKeyValues:entity];
    [dataBaseHandle insertDataWithKeyValues:entity2];
    [dataBaseHandle insertDataWithKeyValues:entity3];
    [dataBaseHandle insertDataWithKeyValues:entity4];
    [dataBaseHandle insertDataWithKeyValues:entity5];
    
    // Update Data
    //[dataBaseHandle updateRssi:-80 x_value:100 y_value:321];
    //[dataBaseHandle updateRssi:-90 x_value:200 y_value:421 ];

    // Delete one of data
    //[dataBaseHandle deleteOneRssi:100 y_value:321];

    // Delete the table
    //[dataBaseHandle dropTable];

    // Do any additional setup after loading the view, typically from a nib.
//    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(182, 30, 10, 10)];
//    view2.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view2];
//    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(49, 770, 10, 10)];
//    view3.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view3];
//    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
//    view4.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view4];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(182, 300, 10, 10)];
    view1.backgroundColor = [UIColor blueColor];
    //UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    //[view1 addSubview:imageView];
    view1.tag = 1;
    [self.view addSubview:view1];
    
    //bluetooth init
    NSLog(@"viewDidLoad");
    peripheralDataArray = [[NSMutableArray alloc] init];
    
    //Initialize BabyBluetooth library
    baby = [BabyBluetooth shareBabyBluetooth];
    //Set bluetooth Delegate (later)
    [self babyDelegate];
    
    //initialize triangulation calculator
    triangulationCalculator = [[TriangulationCalculator alloc]init];
    
    //directly use without waiting for CBCentralManagerStatePoweredOn
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

#pragma mark -Bluetooth config and control

//Bluetooth Delegate setting
-(void)babyDelegate{

    __weak typeof(self) weakSelf = self;
    
    // database opened
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"RssiDB"];

    //Store previous two rssi values
    static int prev_rssi1 = 0;
    static int prevprev_rssi1 = 0;
    static int prev_rssi2 = 0;
    static int prevprev_rssi2 = 0;
    static int prev_rssi3 = 0;
    static int prevprev_rssi3 = 0;
    
    //Store avarge rssi values
    static int avag_rssi_one = 0;
    static int avag_rssi_two = 0;
    static int avag_rssi_three = 0;
    static int ignore_count = 0;

    //Store distance values
    static float distance_one = 0;
    static float distance_two = 0;
    static float distance_three = 0;

    static NSMutableArray *rssi_array_one;
    rssi_array_one = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_two;
    rssi_array_two = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_three;
    rssi_array_three = [[NSMutableArray alloc] init];
    static int flag = 0;
    
    //Handle Delegate
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Searching for different BrtBeacon
        
        if ([peripheral.name isEqual:@"BrtBeacon01"]) {
            if (ignore_count > 50 && [RSSI intValue] != 127) {
                if ( [rssi_array_one count] < 20 ) {
                    [rssi_array_one addObject:RSSI];
                    //NSLog(@"RSSI:%@", RSSI);
                }
                else {
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        container = container + [[rssi_array_one objectAtIndex:i] intValue];
                    }
                    float u = container/20;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_one objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/19),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        if ([[rssi_array_one objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_one objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_one objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_one = rssi_sum / rssi_count;
                    
                    //Moving average Algorithm
                    if (prev_rssi1 == 0 || prevprev_rssi1 == 0) {
                        prev_rssi1 = avag_rssi_one;
                        prevprev_rssi1 = avag_rssi_one;
                    }
                    avag_rssi_one = (avag_rssi_one + prev_rssi1 + prevprev_rssi1)/3;
                    prevprev_rssi1 = prev_rssi1;
                    prev_rssi1 = avag_rssi_one;
                    
                    //Translate RSSI value into distance
                    double txPower = -55;
                    
//                    if (avag_rssi_one == 0) {
//                        distance_one = -1.0;
//                    }
//                    double ratio = avag_rssi_one*1.0/txPower;
//                    if (ratio < 1.0) {
//                        distance_one = pow(ratio,10);
//                    }
//                    else {
//                        distance_one = (0.89976)*pow(ratio,7.7095) + 0.111;
//                    }
                    distance_one = pow(10,((txPower - avag_rssi_one)/22));
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_one, distance_one);
                    [rssi_array_one removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon02"]) {
             if (ignore_count > 50 && [RSSI intValue] != 127) {
                 if ( [rssi_array_two count] < 20 ) {
                     [rssi_array_two addObject:RSSI];
                     //NSLog(@"RSSI:%@", RSSI);
                 }
                 else {
                     NSUInteger count;
                     NSUInteger i;
                     float container = 0;
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         container = container + [[rssi_array_two objectAtIndex:i] intValue];
                     }
                     float u = container/20;
                     float container2 = 0;
                     
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         double temp = 0.0;
                         temp = [[rssi_array_two objectAtIndex:i] doubleValue] - u;
                         //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                         container2 = container2 + pow(temp,2);
                     }
                     float v = pow((container2/19),0.5);
                     //NSLog(@"u:%.lf  v:%.1f", u, v);
                     
                     float rssi_sum = 0;
                     float rssi_count = 0;
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         if ([[rssi_array_two objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_two objectAtIndex:i] doubleValue] > (u-v))
                         {
                             //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                             rssi_sum = rssi_sum + [[rssi_array_two objectAtIndex:i] doubleValue];
                             rssi_count = rssi_count + 1;
                         }
                     }
                     avag_rssi_two = rssi_sum / rssi_count;
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     //Moving average Algorithm
                     if (prev_rssi2 == 0 || prevprev_rssi2 == 0) {
                         prev_rssi2 = avag_rssi_two;
                         prevprev_rssi2 = avag_rssi_two;
                     }
                     avag_rssi_two = (avag_rssi_two + prev_rssi2 + prevprev_rssi2)/3;
                     prevprev_rssi2 = prev_rssi2;
                     prev_rssi2 = avag_rssi_two;
                     
                     //Translate RSSI value into distance
                     double txPower = -50;
 
                     distance_two = pow(10,((txPower - avag_rssi_two)/22));
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     [rssi_array_two removeAllObjects];
                     flag = 1;
                 }
             }
             else {
                 ignore_count = ignore_count + 1;
             }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon03"]) {
            if (ignore_count > 50 && [RSSI intValue] != 127) {
                if ( [rssi_array_three count] < 20 ) {
                    [rssi_array_three addObject:RSSI];
                    NSLog(@"RSSI:%@", RSSI);
                }
                else {
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        container = container + [[rssi_array_three objectAtIndex:i] intValue];
                    }
                    float u = container/20;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_three objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/19),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        if ([[rssi_array_three objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_three objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_three objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_three = rssi_sum / rssi_count;
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);
                    //Moving average Algorithm
                    if (prev_rssi3 == 0 || prevprev_rssi3 == 0) {
                        prev_rssi3 = avag_rssi_three;
                        prevprev_rssi3 = avag_rssi_three;
                    }
                    avag_rssi_three = (avag_rssi_three + prev_rssi3 + prevprev_rssi3)/3;
                    prevprev_rssi3 = prev_rssi3;
                    prev_rssi3 = avag_rssi_three;
                    
                    //Translate RSSI value into distance
                    double txPower = -50;

                    distance_three = pow(10,((txPower - avag_rssi_three)/22));
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);
                    [rssi_array_three removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }

        //ignore the first several data (no coordinate)
        if (flag != 0 && avag_rssi_one !=0 && avag_rssi_two != 0 && avag_rssi_three != 0) {
            //Trilangulation Algorithm
            CGPoint position = [triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one beaconDis2:distance_two beaconDis3:distance_three];
            //NSLog(@" Beacon1: %d, Beacon2: %d, Beacon3: %d With Position = (%f, %f) ", avag_rssi_one, avag_rssi_two, avag_rssi_three, position.x, position.y);
            NSLog(@" Beacon1: %d and %.2f, Beacon2: %d and %.2f, Beacon3: %d and %.2f", avag_rssi_one, distance_one, avag_rssi_two, distance_two, avag_rssi_three, distance_three);
            
            //Fingerprinting Algorithm
            NSMutableArray * xy_one = [dataBaseHandle selectOneByrssi:1 value:avag_rssi_one];
            NSMutableArray * xy_two = [dataBaseHandle selectOneByrssi:2 value:avag_rssi_two];
            NSMutableArray * xy_three = [dataBaseHandle selectOneByrssi:3 value:avag_rssi_three];
            
            NSMutableDictionary * xy_dict = [NSMutableDictionary dictionary];
            
            for (NSString *string in xy_one) {
                //if xy is already in the dictionary
                if ([xy_dict objectForKey:string]) {
                    [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_one + 127) forKey:string];
                }
                //if xy is not in the dictionary
                else {
                    [xy_dict setObject:@(avag_rssi_one) forKey:string];
                }
            }
            for (NSString *string in xy_two) {
                if ([xy_dict objectForKey:string]) {
                    [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_two + 127) forKey:string];
                }
                else {
                    [xy_dict setObject:@(avag_rssi_two) forKey:string];
                }
            }
            for (NSString *string in xy_three) {
                if ([xy_dict objectForKey:string]) {
                    [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_three + 127) forKey:string];
                }
                else {
                    [xy_dict setObject:@(avag_rssi_three) forKey:string];
                }
            }
            //NSLog(@"%@", xy_dict);
            
            NSArray * Sorted_XY = [xy_dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSArray * Seperated_XY = [[Sorted_XY firstObject] componentsSeparatedByString:@" "];
            float finger_x = [[Seperated_XY objectAtIndex:0] floatValue];
            float finger_y = [[Seperated_XY objectAtIndex:1] floatValue];
            
            //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-65];
            //NSLog(@"xyValue: %.1f and %.1f", finger_x, finger_y);

            //Weighted fused results from both Algorithm
            float weighted_x;
            float weighted_y;
            if (finger_x != 0 && finger_y != 0){
                weighted_x = (70*finger_x/100) + (30*position.x/100);
                weighted_y = (70*finger_y/100) + (30*position.y/100);
            }
            else {
                weighted_x = position.x;
                weighted_y = position.y;
            }

            if (position.x != 0) {
                //convert to pixels
                
                //for iphone_7plus
                float x = position.x*76.8;  //384/5
                float y = position.y*38.068 + 39; //670/17.6
                NSLog(@"xyValue: %.1f and %.1f", x, y);
                //for iphone 7 plus
                //float x = weighted_x * 45.1765;
                //float y= weighted_y * 42.9487 + 39;
                for (UIView *i in weakSelf.view.subviews){
                    if([i isKindOfClass:[UIView class]]){
                        UILabel *newLbl = (UILabel *)i;
                        if(newLbl.tag == 1){
                            //change the position of view1
                            i.center = CGPointMake(x, y);
                        }//if
                    }//if
                }//for loop
            }//if
            //set flag back to zero
            flag = 0;
        }
    }];
    
    
    //Set searching filter
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Only search device with this prefix
        if ([peripheralName hasPrefix:@"BrtBeacon"] ) {
            return YES;
        }
        return NO;
    }];
    
    /*
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    */
    
    /*
    //Ignore same Peripherals found
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //connect device->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
