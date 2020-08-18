//
//  MainViewController.m
//  MesiboSample
//
//  Created by Amit on 22/01/18.
//  Copyright © 2018 Mesibo. All rights reserved.
//

#import "MainViewController.h"
#import "includes.h"
#import "UIManager.h"
#import "SampleAppWebApi.h"
#import "UiUtils.h"
#import "MesiboCall/MesiboCall.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLogin:(id)sender {
    [[UIManager getInstance] addProgress:self.view];
    [[UIManager getInstance] showProgress];
    
    
    [SampleAPIInstance login:_mName.text phone:_mPhone.text handler:^(int result, NSDictionary *response) {
        [[UIManager getInstance] hideProgress];
        
        if(MESIBO_RESULT_OK == result) {
            [self dismissViewControllerAnimated:YES completion:nil];
                
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

                
            [UiUtils launchMesiboUI:window.rootViewController withMainWindow:window];
            [MesiboCallInstance start];
            return;
        }
        
        //Handle failure and alert user
        [UiUtils showAlert:@"Try again later" withTitle:@"Login Failed"];
    
    }];
}

@end
