//
//  MainNavViewController.m
//  气压控制
//
//  Created by 0xfeedface on 16/3/8.
//  Copyright © 2016年 virus1993. All rights reserved.
//

#import "MainNavViewController.h"

typedef NS_ENUM(NSInteger, TexTFieldType) {
    TexTFieldIP,
    TexTFieldPort
};

@interface MainNavViewController ()
@property (nonatomic, strong) UIView *inputIPView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UITextField *ip;
@property (nonatomic, strong) UITextField *port;
@end

@implementation MainNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *ip = [[NSUserDefaults standardUserDefaults] valueForKey: @"ip"];
    NSString *port = [[NSUserDefaults standardUserDefaults] valueForKey: @"port"];
    
    if (ip == nil || port == nil) {
        [self changeServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)changeServer {
    UIView *inputIPView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    inputIPView.backgroundColor = [UIColor whiteColor];
    self.inputIPView = inputIPView;
    [self.view addSubview:inputIPView];
    
    UILabel *ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 90, 25)];
    ipLabel.text = @"服务器IP:";
    ipLabel.font = [UIFont systemFontOfSize:15];
    ipLabel.textAlignment = NSTextAlignmentRight;
    [inputIPView addSubview:ipLabel];
    
    UITextField *ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(145, 200, 145, 25)];
    ipTextField.placeholder = @"  ip";
    ipTextField.textAlignment = NSTextAlignmentLeft;
    ipTextField.delegate = self;
    ipTextField.tag = TexTFieldIP;
    ipTextField.layer.borderWidth = 1;
    ipTextField.layer.borderColor = [UIColor grayColor].CGColor;
    ipTextField.keyboardType = UIKeyboardTypeDecimalPad;
    //ipTextField.backgroundColor = [UIColor grayColor];
    self.ip = ipTextField;
    [inputIPView addSubview:ipTextField];
    
    UILabel *portLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 255, 90, 25)];
    portLabel.text = @"服务器端口:";
    portLabel.font = [UIFont systemFontOfSize:15];
    portLabel.textAlignment = NSTextAlignmentRight;
    [inputIPView addSubview:portLabel];
    
    UITextField *portTextField = [[UITextField alloc] initWithFrame:CGRectMake(145, 255, 145, 25)];
    portTextField.placeholder = @"  端口";
    portTextField.textAlignment = NSTextAlignmentLeft;
    portTextField.delegate = self;
    portTextField.tag = TexTFieldPort;
    portTextField.layer.borderWidth = 1;
    portTextField.layer.borderColor = [UIColor grayColor].CGColor;
    portTextField.keyboardType = UIKeyboardTypeNumberPad;
    //portTextField.backgroundColor = [UIColor grayColor];
    self.port = portTextField;
    [inputIPView addSubview:portTextField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(110, 80, 100, 100);
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:25 weight:2];
    button.tintColor = [UIColor redColor];
    button.layer.cornerRadius = 50;
    button.layer.borderWidth = 5;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.masksToBounds = NO;
    [button addTarget:self action:@selector(setIPPort) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton = button;
    self.confirmButton.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    [inputIPView addSubview:button];
}

-(void)configIP:(NSString *)text port:(NSString *)port {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:text forKey:@"ip"];
    [userDefaults setObject:port forKey:@"port"];
}

- (void)setIPPort {
    [self configIP:self.ip.text port:self.port.text];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
    self.inputIPView.hidden = YES;
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
- (void)textFieldDidChange:(NSNotification *)notification{
    NSLog(@"%@", notification.userInfo);
    if ([[self.ip text] rangeOfString:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionSearch].length > 0 && self.port.text.length > 0) {
        self.confirmButton.hidden = NO;
        return;
    }
    self.confirmButton.hidden = YES;
}

@end
