//
//  ViewController.m
//  MesiboObjCSample
//
//  Copyright © 2020 Mesibo. All rights reserved.
//

#import "ViewController.h"
#import "MesiboSample.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)OnSendMessage:(id)sender {
    [[MesiboSample getInstance] sendMessage:@"destination" message:@"Hello, mesibo"];
}

@end
