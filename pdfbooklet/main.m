/*
 Copyright 2016 Tim Mecking

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

void error(NSString* string) {
	fputs([string UTF8String], stderr);
	exit(2);
}
void usage() {
	puts("Usage: pdfbooklet <inputfile> <outputfile>");
	exit(1);
}

CGPDFDocumentRef docRef = NULL;
CGContextRef contextRef = NULL;
NSInteger numberOfInputPages = 0;
NSInteger numberOfOutputPages = 0;
CGRect mediaBox;

void writePage(NSInteger pageNumber) {
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(docRef, pageNumber);

	if(pageRef != NULL) {
		CGRect pageMediaBox=CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
		CGContextBeginPage(contextRef, &pageMediaBox);
		CGContextDrawPDFPage(contextRef, pageRef);
		CGContextEndPage(contextRef);
	}
	else {
		if(CGRectIsNull(mediaBox)) {
			pageRef = CGPDFDocumentGetPage(docRef, 1);
			if(pageRef != NULL) {
				mediaBox = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
			}
		}
		CGContextBeginPage(contextRef, &mediaBox);
		CGContextEndPage(contextRef);
	}
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if(argc!=3) usage();
		if(argv[1][0]=='-') usage();
		if(argv[2][0]=='-') usage();

		mediaBox=CGRectNull;

		NSString* inputFile=[NSString stringWithUTF8String:argv[1]];
		if(![[NSFileManager defaultManager] fileExistsAtPath:inputFile]) {
			error([NSString stringWithFormat:@"Input File \"%@\" not found\n",inputFile]);
		}
		NSURL* inputURL = [NSURL fileURLWithPath:inputFile];
		docRef=CGPDFDocumentCreateWithURL((__bridge CFURLRef)inputURL);
		if(!docRef) {
			error([NSString stringWithFormat:@"Cannot read \"%@\"\n",inputFile]);
		}

		NSString* outputFile=[NSString stringWithUTF8String:argv[2]];
		if(![outputFile hasSuffix:@".pdf"]) outputFile=[outputFile stringByAppendingString:@".pdf"];
		NSURL* outputURL = [NSURL fileURLWithPath:outputFile];
		contextRef=CGPDFContextCreateWithURL((__bridge CFURLRef)outputURL, NULL, NULL);
		if(!contextRef) {
			CGPDFDocumentRelease(docRef);
			error([NSString stringWithFormat:@"Cannot create \"%@\"\n",outputFile]);
		}

		numberOfInputPages=CGPDFDocumentGetNumberOfPages(docRef);
		numberOfOutputPages=numberOfInputPages;
		if(numberOfInputPages % 4 != 0) {
			numberOfOutputPages += 4 - numberOfInputPages % 4;
		}

		for(NSInteger i=0 ; i<numberOfOutputPages/4 ; i++) {
			writePage(numberOfOutputPages - 2*i);
			writePage(1 + 2*i);
			writePage(2 + 2*i);
			writePage(numberOfOutputPages - 1 - 2*i);
		}

		CGPDFContextClose(contextRef);
		CGContextRelease(contextRef);
		CGPDFDocumentRelease(docRef);

		NSString* message=[NSString stringWithFormat:@"Now print \"%@\" with layout settings:\n"
						   "- Pages per Sheet: 2\n"
						   "- Layout Direction: first option (2)\n"
						   "- Two Sided: Short-Edge Binding\n",inputFile];
		puts([message UTF8String]);
	}
    return 0;
}
