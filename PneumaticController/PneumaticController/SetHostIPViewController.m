//
//  SetHostIPViewController.m
//  气压控制
//
//  Created by 0xfeedface on 16/3/7.
//  Copyright © 2016年 virus1993. All rights reserved.
//

#import "SetHostIPViewController.h"

typedef NS_ENUM(NSInteger, TexTFieldType) {
    TexTFieldIP,
    TexTFieldPort
};

@interface SetHostIPViewController ()

@end

@implementation SetHostIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] valueForKey: @"ip"];
    NSString *port = [[NSUserDefaults standardUserDefaults] valueForKey: @"port"];
    
    if (ip == nil || port == nil) {
        [self changeServer];
    }   else    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeServer {
    
    NSString *title = @"请设置你的服务器ip";
    NSString *message;
    //对话框弹出
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self configIP:alertController.textFields.firstObject.text
                  port:alertController.textFields.lastObject.text];
        //self.title = @"正在连接...";
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidChangeNotification
                                                      object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    okAction.enabled = NO;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    //添加ok、cancel和输入文本框
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *titleIP = [userDefaults valueForKey:@"ip"];
        textField.text = titleIP;
        textField.placeholder = @"请输入服务器的ip";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.tag = TexTFieldIP;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *port = [userDefaults valueForKey:@"ip"];
        textField.text = port;
        textField.placeholder = @"请输入服务器的端口";
        textField.tag = TexTFieldPort;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)configIP:(NSString *)text port:(NSString *)port {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:text forKey:@"ip"];
    [userDefaults setObject:port forKey:@"port"];
}

#pragma mark - 输入检查

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == TexTFieldIP) {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]invertedSet];
        // allow backspace
        if (range.length > 0 && [string length] == 0) {
            return YES;
        }
        // do not allow . at the beggining
        if (range.location == 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        // currentField指的是当前确定的那个输入框,当前面的字符有小数点的时候就不替换
        NSString *currentText = textField.text;
        if (([string isEqualToString:@"."] && [currentText rangeOfString:@"." options:NSBackwardsSearch|NSAnchoredSearch].length == 1)) {
            string = @"";
            //alreay has a decimal point
            return NO;
        }
        
        NSString *newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
        
        if ([newValue rangeOfString:@"(\\d{1,}\\.){4}" options:NSRegularExpressionSearch].length > 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 输入框为空ok键不激活
- (void)alertTextFieldDidChange:(NSNotification *)notification{
    NSLog(@"%@", notification.userInfo);
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UIAlertAction *okAction = alertController.actions.firstObject;
        BOOL isEnableOK = YES;
        for (UITextField *textField in alertController.textFields) {
            if (textField.tag == TexTFieldIP) {
                if ([[textField text] rangeOfString:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionSearch].length == 0) {
                    isEnableOK = NO;
                }
            }   else {
                if ([textField text].length == 0) {
                    isEnableOK = NO;
                }
            }
        }
        okAction.enabled = isEnableOK;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
