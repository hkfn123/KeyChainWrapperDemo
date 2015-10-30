//
//  ViewController.m
//  KeyChainWrapperDemo
//
//  Created by jajeo on 10/29/15.
//  Copyright (c) 2015 jajeo. All rights reserved.
//

#import "ViewController.h"
#import "KeyChainWrapper.h"

@interface ViewController (){
    __weak IBOutlet UITextField *_sServiceNameTF;
    __weak IBOutlet UITextField *_sGroupNameTF;
    __weak IBOutlet UITextField *_sKeyTF;
    __weak IBOutlet UITextField *_sValueNameTF;
    __weak IBOutlet UITextField *_gServiceNameTF;
    __weak IBOutlet UITextField *_gGroupNameTF;
    __weak IBOutlet UITextField *_gKeyTF;
    __weak IBOutlet UILabel     *_gValueNameLb;
    
    NSString                    *_groupName;
    NSString                    *_serviceName;
    NSString                    *_key;
    NSData                      *_value;
}

- (IBAction)btnClickAction:(UIButton *)btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnClickAction:(UIButton *)btn{
    if (btn.tag == 100) {
        _groupName = _sGroupNameTF.text;
        _serviceName = _sServiceNameTF.text;
        _key = _sKeyTF.text;
        NSString *value = _sValueNameTF.text;
        _value = nil;
        if (value) {
            _value = [value dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        BOOL success = [[KeyChainWrapper keyChainWithService:_serviceName withGroupName:_groupName] setData:_value forKey:_key];
        if (success) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"添加成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    }
    
    if (btn.tag == 101) {
        _groupName = _gGroupNameTF.text;
        _serviceName = _gServiceNameTF.text;
        _key = _gKeyTF.text;
        
        _value = [[KeyChainWrapper keyChainWithService:_serviceName withGroupName:_groupName] dataForKey:_key];
        if (_value && _value.length > 0) {
            _gValueNameLb.text = [[NSString alloc] initWithData:_value encoding:NSUTF8StringEncoding];
        } else{
            _gValueNameLb.text = @"";
        }
    }
}

@end
