//
//  ViewController.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//
#import <Foundation/Foundation.h>
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
//    //database control
//    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"RssiDB"];
//
//    // Find all points in the database
//    NSArray * allPoints = [dataBaseHandle selectAllKeyValues];
//
//    // Insert Data (examples)
//    RssiEntity * entity = [[RssiEntity alloc] init];
//    entity.number = 1 ;
//    entity.x = 100;
//    entity.y = 321;
//    entity.beacon = 1;
//    entity.value = -65;
//
//    RssiEntity * entity2 = [[RssiEntity alloc] init];
//    entity2.number = 2 ;
//    entity2.x = 200;
//    entity2.y = 421;
//    entity2.beacon = 2;
//    entity2.value = -66;
//
//    [dataBaseHandle insertDataWithKeyValues:entity];
//    [dataBaseHandle insertDataWithKeyValues:entity2];
//
//    // Select all data
//    allPoints = [dataBaseHandle selectAllKeyValues];
//    NSLog(@"%ld", [allPoints count]);
//
//    // Update Data
//    [dataBaseHandle updateRssi:-80 x_value:100 y_value:321];
//    [dataBaseHandle updateRssi:-90 x_value:200 y_value:421 ];
//
//    // Select one of data
//    RssiEntity * selectRssi = [dataBaseHandle selectOneByNumber:1];
//    RssiEntity * selectRssi2 = [dataBaseHandle selectOneByNumber:2];
//    NSLog(@"%ld", selectRssi.value);
//    NSLog(@"%ld", selectRssi2.value);
//
//    // Delete one of data
//    [dataBaseHandle deleteOneRssi:100 y_value:321];
//
//    // Find all points in the database
//    allPoints = [dataBaseHandle selectAllKeyValues];
//    NSLog(@"%ld", [allPoints count]);
//
//    // Delete the table
//    [dataBaseHandle dropTable];

    // Do any additional setup after loading the view, typically from a nib.
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(182, 30, 10, 10)];
    //   UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 30, 30)];
    view2.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view2];
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(49, 770, 10, 10)];
     // UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(384, 39, 30, 30)];
    view3.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view3];
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
    //UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 709, 30, 30)];
    view4.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view4];
    
    //UIView *view5 = [[UIView alloc] initWithFrame:CGRectMake(384, 709, 30, 30)];
    //view5.backgroundColor = [UIColor orangeColor];
    //[self.view addSubview:view5];
    
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
    
    //Handle Delegate
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Searching for different BrtBeacon
        
        if ([peripheral.name isEqual:@"BrtBeacon01"]) {
            if (ignore_count > 100) {
                if ( [rssi_array_one count] < 40 ) {
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
                    float u = container/40;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_one objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/39),0.5);
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
                    if (prev_rssi1 == 0) {
                        prev_rssi1 = avag_rssi_one;
                    }
                    if (prevprev_rssi1 == 0) {
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
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon02"]) {
             if (ignore_count > 100) {
                 if ( [rssi_array_two count] < 40 ) {
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
                     float u = container/40;
                     float container2 = 0;
                     
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         double temp = 0.0;
                         temp = [[rssi_array_two objectAtIndex:i] doubleValue] - u;
                         //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                         container2 = container2 + pow(temp,2);
                     }
                     float v = pow((container2/39),0.5);
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
                     if (prev_rssi2 == 0) {
                         prev_rssi2 = avag_rssi_two;
                     }
                     if (prevprev_rssi2 == 0) {
                         prevprev_rssi2 = avag_rssi_two;
                     }
                     avag_rssi_two = (avag_rssi_two + prev_rssi2 + prevprev_rssi2)/3;
                     prevprev_rssi2 = prev_rssi2;
                     prev_rssi2 = avag_rssi_two;
                     
                     //Translate RSSI value into distance
                     double txPower = -50;
//
//                     if (avag_rssi_two == 0) {
//                         distance_two = -1.0;
//                     }
//                     double ratio = avag_rssi_two*1.0/txPower;
//                     if (ratio < 1.0) {
//                         distance_two = pow(ratio,10);
//                     }
//                     else {
//                         distance_two = (0.89976)*pow(ratio,7.7095) + 0.111;
//                     }
                     distance_two = pow(10,((txPower - avag_rssi_two)/22));
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     [rssi_array_two removeAllObjects];
                 }
             }
             else {
                 ignore_count = ignore_count + 1;
             }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon03"]) {
            if (ignore_count > 100) {
                if ( [rssi_array_three count] < 40 ) {
                    [rssi_array_three addObject:RSSI];
                    //NSLog(@"RSSI:%@", RSSI);
                }
                else {
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        container = container + [[rssi_array_three objectAtIndex:i] intValue];
                    }
                    float u = container/40;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_three objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/39),0.5);
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
                    
                    //Moving average Algorithm
                    if (prev_rssi3 == 0) {
                        prev_rssi3 = avag_rssi_three;
                    }
                    if (prevprev_rssi3 == 0) {
                        prevprev_rssi3 = avag_rssi_three;
                    }
                    avag_rssi_three = (avag_rssi_three + prev_rssi3 + prevprev_rssi3)/3;
                    prevprev_rssi3 = prev_rssi3;
                    prev_rssi3 = avag_rssi_three;
                    
                    //Translate RSSI value into distance
                    double txPower = -55;
                    
//                    if (avag_rssi_three == 0) {
//                        distance_three = -1.0;
//                    }
//                    double ratio = avag_rssi_three*1.0/txPower;
//                    if (ratio < 1.0) {
//                        distance_three = pow(ratio,10);
//                    }
//                    else {
//                        distance_three = (0.89976)*pow(ratio,7.7095) + 0.111;
//                    }
                    distance_three = pow(10,((txPower - avag_rssi_three)/22));
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);
                    [rssi_array_three removeAllObjects];
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        //Used to list the relations between rssi and distance
        //          int avag_rssi_one = -69;
        //              while(avag_rssi_one > -88)
        //              {
        //              //Translate RSSI value into distance
        //                  double txPower = -65;
        //
        //                  if (avag_rssi_one == 0) {
        //                      distance_one = -1.0;
        //                  }
        //                  double ratio = avag_rssi_one*1.0/txPower;
        //                  if (ratio < 1.0) {
        //                      distance_one = pow(ratio,10);
        //                  }
        //                  else {
        //                      distance_one = (0.89976)*pow(ratio,7.7095) + 0.111;
        //                  }
        //                  NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_one, distance_one);
        //                  distance_one = pow(10,((txPower - avag_rssi_one)/22));
        //                  NSLog(@"ANOTHER: %.1f meters", distance_one);
        //                  avag_rssi_one = avag_rssi_one - 1;
        //              }

        //ignore the first several data (no coordinate)

        if (distance_one != 0 && distance_two != 0 && distance_three != 0) {
            CGPoint position = [triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one*100 beaconDis2:distance_two*100 beaconDis3:distance_three*100];
            //NSLog(@" Beacon1: %d, Beacon2: %d, Beacon3: %d With Position = (%f, %f) ", avag_rssi_one, avag_rssi_two, avag_rssi_three, position.x, position.y);
            NSLog(@" Beacon1: %d and %.2f, Beacon2: %d and %.2f, Beacon3: %d and %.2f", avag_rssi_one, distance_one, avag_rssi_two, distance_two, avag_rssi_three, distance_three);
            if (position.x != 0) {
                //convert to pixels


                //for iphoneX
                float x = position.x*33.5294+49;
                float y = position.y*47.4359+30;
                //for iphone 7 plus
                //float x = position.x * 45.1765;
                //float y= position.y * 42.9487 + 39;
                for (UIView *i in weakSelf.view.subviews){
                    if([i isKindOfClass:[UIView class]]){
                        UILabel *newLbl = (UILabel *)i;
                        if(newLbl.tag == 1){
                            //change the position of view1
                            i.center = CGPointMake(x, y);
                        }//if
                    }//if
                }//for loop
            }
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
