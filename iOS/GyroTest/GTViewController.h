//
//  GTViewController.h
//  GyroTest
//
//  Created by Jon on 5/25/13.
//  Copyright (c) 2013 Jon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLE.h"

@interface GTViewController : UIViewController <BLEDelegate>

@property (strong, nonatomic) BLE *ble;

@end
