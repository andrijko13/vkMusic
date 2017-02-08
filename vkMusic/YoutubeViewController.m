//
//  YoutubeViewController.m
//  vkMusic
//
//  Created by Andriy Suden on 1/23/17.
//  Copyright © 2017 DropGeeks. All rights reserved.
//

#import "YoutubeViewController.h"
#import "AppDelegate.h"

@interface YoutubeViewController () {
    NSMutableData *_receivedData;
    long long _expectedBytes;
    NSString *_fileName;
    NSString *_songTitle;
}
@end

@implementation YoutubeViewController
@synthesize _progress;
@synthesize _downloadLabel;
@synthesize _delegate;
@synthesize _searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    self._delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _searchBar.delegate = self;
    NSLog(@"Entered");
    // Do any additional setup after loading the view.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *url = [NSString stringWithFormat:@"%@", searchBar.text];
    
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://www.youtubeinmp3.com/fetch/?format=JSON&video=%@", url];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    _songTitle = [[json valueForKey:@"title"] stringByAppendingString:@".mp3"];
    _fileName = [NSString stringWithFormat:@"%@/music/%@", documentsDirectory,_songTitle];
    
    url = [json valueForKey:@"link"];
    
    [self downloadFromURL:url name:_songTitle];
    
    [_searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadFromURL:(NSString *)urlToDownload name:(NSString *)fileName{
    NSLog(@"Downloading Started");
    NSURL  *url = [NSURL URLWithString:urlToDownload];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    _receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection __unused = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Received response from connection");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _progress.hidden = NO;
    _downloadLabel.hidden = NO;
    [_receivedData setLength:0];
    _expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Received data from connection");
    [_receivedData appendData:data];
    float progressive = (float)[_receivedData length] / (float)_expectedBytes;
    [_progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Download Failed");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[currentURL stringByAppendingString:@".mp3"]];
    NSLog(@"Succeeded! Received %lu bytes of data",[_receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData writeToFile:_fileName atomically:YES];
    _progress.hidden = YES;
    _downloadLabel.hidden = YES;
    [self._delegate fileDidDownload:_songTitle];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)_backButton:(id)sender {
    [self performSegueWithIdentifier:@"back_segue" sender:self];
}
@end
