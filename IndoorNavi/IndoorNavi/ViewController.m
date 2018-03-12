//
//  ViewController.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import "TriangulationAlgorithm.h"

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
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(150, 150, 20, 20)];
    view1.backgroundColor = [UIColor blueColor];
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
    
    //__weak typeof(self) weakSelf = self;

    //Store previous two rssi value
    static int prev_rssi1 = 0;
    static int prevprev_rssi1 = 0;
    static int prev_rssi2 = 0;
    static int prevprev_rssi2 = 0;
    static int prev_rssi3 = 0;
    static int prevprev_rssi3 = 0;
    static int avag_rssi_one = 0;
    static int avag_rssi_two = 0;
    static int avag_rssi_three = 0;
    static float distance_one = 0;
    static float distance_two = 0;
    static float distance_three = 0;
    
    //Handle Delegate
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Searching for different BrtBeacon
        if ([peripheral.name isEqual:@"BrtBeacon01"]) {
            
            if (prev_rssi1 == 0) {
                prev_rssi1 = [RSSI intValue];
            }
            if (prevprev_rssi1 == 0) {
                prevprev_rssi1 = [RSSI intValue];
            }
            avag_rssi_one = ([RSSI intValue] + prev_rssi1 + prevprev_rssi1)/3;
            //NSLog(@"%@ has RSSI: %@ and %@",peripheral.name, RSSI, avag_rssi);
            
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
            NSLog(@"%@ has RSSI: %@ average: %d and %.1f meters", peripheral.name, RSSI, avag_rssi_one, distance_one);
            prevprev_rssi1 = prev_rssi1;
            prev_rssi1 = avag_rssi_one;
        }
        if ([peripheral.name isEqual:@"BrtBeacon02"]) {
            
            if (prev_rssi2 == 0) {
                prev_rssi2 = [RSSI intValue];
            }
            if (prevprev_rssi2 == 0) {
                prevprev_rssi2 = [RSSI intValue];
            }
            avag_rssi_two = ([RSSI intValue] + prev_rssi2 + prevprev_rssi2)/3;
            //NSLog(@"%@ has RSSI: %@ and %@",peripheral.name, RSSI, avag_rssi);
            
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
            NSLog(@"%@ has RSSI: %@ average: %d and %.1f meters", peripheral.name, RSSI, avag_rssi_two, distance_two);
            prevprev_rssi2 = prev_rssi2;
            prev_rssi2 = avag_rssi_two;
        }
        if ([peripheral.name isEqual:@"BrtBeacon03"]) {
            
            if (prev_rssi3 == 0) {
                prev_rssi3 = [RSSI intValue];
            }
            if (prevprev_rssi3 == 0) {
                prevprev_rssi3 = [RSSI intValue];
            }
            avag_rssi_three = ([RSSI intValue] + prev_rssi3 + prevprev_rssi3)/3;
            //NSLog(@"%@ has RSSI: %@ and %@",peripheral.name, RSSI, avag_rssi);
            
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
            NSLog(@"%@ has RSSI: %@ average: %d and %.1f meters", peripheral.name, RSSI, avag_rssi_three, distance_three);
            prevprev_rssi3 = prev_rssi3;
            prev_rssi3 = avag_rssi_three;
        }
        
        //ignore the first several data (no coordinate)
        if (distance_one != 0 && distance_two != 0 && distance_three != 0) {
            CGPoint position = [triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one*100 beaconDis2:distance_two*100 beaconDis3:distance_three*100];
            NSLog(@"Position = (%f, %f) ", position.x, position.y);
            float x = position.x/10;
            float y = position.y/10;
            
            for (UIView *i in self.view.subviews){
                if([i isKindOfClass:[UIView class]]){
                    UILabel *newLbl = (UILabel *)i;
                    if(newLbl.tag == 1){
                        /// Write your code
                        i.backgroundColor = [UIColor blueColor];
                        i.center = CGPointMake(x, y);
                    }//if
                }//if
            }//for loop
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
