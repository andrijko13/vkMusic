//
//  TableViewCell.h
//  vkMusic
//
//  Created by Andriy Suden on 4/20/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewCell;

@protocol VKCellPlay<NSObject>
-(void) playFromHTTP:(NSURL *)url title:(NSString *)title cell:(TableViewCell *)cell;
@end

@interface TableViewCell : UITableViewCell
{
}
- (IBAction)_buttonClicked:(id)sender;
@property (strong, nonatomic) NSString *_url;
@property (weak, nonatomic) IBOutlet UILabel *_title;
@property (readwrite, unsafe_unretained) id<VKCellPlay> _delegate;

@end
