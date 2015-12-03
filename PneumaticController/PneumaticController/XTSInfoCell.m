//
//  XTSInfoCell.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSInfoCell.h"

#define kLabelTextColor [UIColor colorWithRed:1.0f green:0.1f blue:0.2f alpha:0.8f]

@implementation XTSInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // TODO - use Auto Layout to adjust sizes
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 15.0, 67.0, 15.0)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont boldSystemFontOfSize:15];
        self.label.textAlignment = NSTextAlignmentRight;
        self.label.textColor = kLabelTextColor;
        self.label.text = @"无状态";
        [self.contentView addSubview:self.label];
    }
    return self;
}

#pragma mark - Property Overrides

/*
- (id)value
{
    return self.textField.text;
}

- (void)setValue:(id)newValue
{
    if ([newValue isKindOfClass:[NSString class]])
        self.textField.text = newValue;
    else
        self.textField.text = [newValue description];
}

#pragma mark - Instance Methods

- (BOOL)isEditable
{
    return NO;
}
*/

@end
