//
//  XTSAutoSetCell.m
//  PneumaticController
//
//  Created by virus1993 on 15/12/3.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSAutoSetCell.h"

@implementation XTSAutoSetCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       // self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // TODO - use Auto Layout to adjust sizes
        self.pressure=[[UILabel alloc] initWithFrame:CGRectMake(80, 11, 100, 21)];
        self.pressure.text=@"";
        
        //self.time=[[UILabel alloc] initWithFrame:CGRectMake(215, 11, 38, 21)];
        //self.time.text=@"";
        self.label.text = @"";
        self.textLabel.text=@"";
        //self.selectionStyle=UITableViewCellSelectionStyleBlue;
        [self.contentView addSubview:self.pressure];
        [self.contentView addSubview:self.time];
    }
    return self;
}

@end
