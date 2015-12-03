//
//  XTSTextCell.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSStateCell.h"

@implementation XTSStateCell

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
         UIImage *image=[UIImage imageNamed:@"黑色按钮.png"];
         self.stateImage=image;
         self.stateImageView=[[UIImageView alloc] initWithFrame:CGRectMake(270.0,7.0, 25, 25)];
         [self.stateImageView setImage:self.stateImage];
         [self.contentView addSubview:self.self.stateImageView];
    }
    return self;
}

@end
