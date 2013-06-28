//
//  GTViewController.m
//  GyroTest
//
//  Created by Jon on 5/25/13.
//  Copyright (c) 2013 Jon. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "GTViewController.h"
#import "TTTLocationFormatter.h"

@interface GTViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *signalStrengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *magnetSpeedLabel;

@property (strong, nonatomic) NSDate *lastGyroUpdate;
@property (nonatomic) float angularVelocity;
@property (nonatomic) float seeduinoAngularVelocity;
@property (nonatomic) float currentAngle;
@property (nonatomic) int manualRevolutionsCount;

@property (nonatomic) BOOL isRunning;

@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.ble = [[BLE alloc] init];
    [self.ble controlSetup:1];
    self.ble.delegate = self;
}

-(void) bleDidConnect {
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [self.connectingIndicator stopAnimating];
    
    self.angularVelocity = 0;
    self.seeduinoAngularVelocity = 0;
    self.currentAngle = 0;
    self.manualRevolutionsCount = 0;
    self.lastGyroUpdate = [NSDate date];
}
 
- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");
    
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectingIndicator stopAnimating];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    self.signalStrengthLabel.text = rssi.stringValue;
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length {
    
    float timeSinceLastUpdate = ABS([self.lastGyroUpdate timeIntervalSinceNow]);
    
    if (timeSinceLastUpdate >= 0.1) {
        static int GyroByte = 0x0A;
        // parse data, all commands are in 3-byte
        for (int i = 0; i < length; i+=3)
        {
            if (data[i] == GyroByte) {
                int value;
                
                value = data[i+2] | data[i+1] << 8;
                //lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
                self.lastGyroUpdate = [NSDate date];
                
                double gyroVoltage = 5000.0f;         //Gyro is running at 5V
                double gyroZeroValue = (281.0f / 1023.0f) * gyroVoltage;   //Gyro is zeroed at 1.35V
                double gyroSensitivity = 0.67f;  //Our example gyro is 6.7mV/deg/sec/sec
                
                //convert analog value to millivolts
                double gyroRate = value;
                gyroRate = (gyroRate / 1023.0f) * gyroVoltage;
                gyroRate = gyroRate - gyroZeroValue;
                
                //This line divides the voltage we found by the gyro's sensitivity
                gyroRate /= gyroSensitivity;
                
                if (gyroRate >= 1 || gyroRate <= -1) {
                    self.angularVelocity += (gyroRate * timeSinceLastUpdate);
                }
                
                self.currentAngle += self.angularVelocity * timeSinceLastUpdate / M_PI;
                NSLog(@"%f  %f  %d  %f", timeSinceLastUpdate, gyroRate, value, self.currentAngle);
                
                float metersPerSecond = ABS((self.angularVelocity / 360) * 2.09858) * timeSinceLastUpdate;
                
                TTTLocationFormatter *formatter = [[TTTLocationFormatter alloc] init];
                formatter.numberFormatter.maximumSignificantDigits = 3;
                formatter.unitSystem = TTTImperialSystem;
                NSString *speedString = [formatter stringFromSpeed:metersPerSecond];
                self.speedLabel.text = speedString;
            }
        }

    }
}

- (IBAction)onTickButton:(id)sender {
    /*NSLog(@"Tick!");
    float revolutionDuration = ABS([self.lastMagnetPass timeIntervalSinceNow]);
    float metersPerSecondMagnet = 2.09858 / revolutionDuration;
    self.lastMagnetPass = [NSDate date];
    
    TTTLocationFormatter *formatter = [[TTTLocationFormatter alloc] init];
    formatter.unitSystem = TTTImperialSystem;
    formatter.numberFormatter.maximumSignificantDigits = 3;
    NSString *speedString = [formatter stringFromSpeed:metersPerSecondMagnet];
    self.magnetSpeedLabel.text = speedString;*/
    
    self.manualRevolutionsCount++;
    self.magnetSpeedLabel.text = [NSString stringWithFormat:@"Revolutions: %d", self.manualRevolutionsCount];
}

#pragma Mark - creating the connection.
- (IBAction)onConnectButton:(id)sender {
    /*[self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
     TTTLocationFormatter *formatter = [[TTTLocationFormatter alloc] init];
     formatter.unitSystem = TTTImperialSystem;
     float metersPerSecond = ABS((gyroData.rotationRate.z / (22/7)) * 2.09858);
     NSString *speedString = [formatter stringFromSpeed:metersPerSecond];
     self.outputTextView.text = [NSString stringWithFormat:@"%@\n%@", self.outputTextView.text, speedString];
     }];*/
    
    if (self.ble.activePeripheral)
        if(self.ble.activePeripheral.isConnected)
        {
            [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            self.manualRevolutionsCount = 0;
            self.angularVelocity = 0;
            return;
        }
    
    if (self.ble.peripherals)
        self.ble.peripherals = nil;
    
    [self.connectButton setEnabled:false];
    [self.ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [self.connectingIndicator startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    [self.connectButton setEnabled:true];
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (self.ble.peripherals.count > 0)
    {
        [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [self.connectingIndicator stopAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
