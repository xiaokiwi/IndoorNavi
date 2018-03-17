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
    // Do any additional setup after loading the view, typically from a nib.
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(49, 30, 30, 30)];
    view2.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view2];
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(315, 30, 30, 30)];
    view3.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view3];
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(182, 605, 30, 30)];
    view4.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view4];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
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
            if (ignore_count > 20) {
                if ( [rssi_array_one count] < 10 ) {
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
                    float u = container/10;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_one objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/9),0.5);
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
                    
                    //Translate RSSI value into distance
                    double txPower = -65;
                    
                    if (avag_rssi_one == 0) {
                        distance_one = -1.0;
                    }
                    double ratio = avag_rssi_one*1.0/txPower;
                    if (ratio < 1.0) {
                        distance_one = pow(ratio,10);
                    }
                    else {
                        distance_one = (0.89976)*pow(ratio,7.7095) + 0.111;
                    }
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_one, distance_one);
                    [rssi_array_one removeAllObjects];
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon02"]) {
             if (ignore_count > 20) {
                 if ( [rssi_array_two count] < 10 ) {
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
                     float u = container/10;
                     float container2 = 0;
                     
                     for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                         double temp = 0.0;
                         temp = [[rssi_array_two objectAtIndex:i] doubleValue] - u;
                         //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                         container2 = container2 + pow(temp,2);
                     }
                     float v = pow((container2/9),0.5);
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
                     
                     //Translate RSSI value into distance
                     double txPower = -65;
                     
                     if (avag_rssi_two == 0) {
                         distance_two = -1.0;
                     }
                     double ratio = avag_rssi_two*1.0/txPower;
                     if (ratio < 1.0) {
                         distance_two = pow(ratio,10);
                     }
                     else {
                         distance_two = (0.89976)*pow(ratio,7.7095) + 0.111;
                     }
                     //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                     [rssi_array_two removeAllObjects];
                 }
             }
             else {
                 ignore_count = ignore_count + 1;
             }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon03"]) {
            if (ignore_count > 20) {
                if ( [rssi_array_three count] < 10 ) {
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
                    float u = container/10;
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_three objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/9),0.5);
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
                    
                    //Translate RSSI value into distance
                    double txPower = -65;
                    
                    if (avag_rssi_three == 0) {
                        distance_three = -1.0;
                    }
                    double ratio = avag_rssi_three*1.0/txPower;
                    if (ratio < 1.0) {
                        distance_three = pow(ratio,10);
                    }
                    else {
                        distance_three = (0.89976)*pow(ratio,7.7095) + 0.111;
                    }
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
            CGPoint position = [triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one*100+200 beaconDis2:distance_two*100+200 beaconDis3:distance_three*100+200];
            NSLog(@" Beacon1: %.1f, Beacon2: %.1f, Beacon3: %.1f With Position = (%f, %f) ", distance_one, distance_two, distance_three, position.x, position.y);
            
            if (position.x != 0) {
                //convert to pixels
                float x = position.x*0.7189+49;
                float y = position.y*0.7189+30;
            
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
