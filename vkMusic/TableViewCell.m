//
//  TableViewCell.m
//  vkMusic
//
//  Created by Andriy Suden on 4/20/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "TableViewCell.h"
#import "AppDelegate.h"

@implementation TableViewCell
@synthesize _url;
@synthesize _title;

- (void)awakeFromNib {
    [super awakeFromNib];
    _url = nil;
    self._delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)_buttonClicked:(id)sender {
    NSLog(@"Button Clicked: %@", _url);
    [self._delegate playFromHTTP:[NSURL URLWithString:_url] title:[_title text] cell:self];
}
@end
