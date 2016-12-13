# PDF Booklet

OS X / macOS command line utility to reorder pages in a PDF file for booklet printing.

pdfbooklet copies pages from a pdf file to a new pdf file in an order appropriate for booklet 
printing. If the number of pages in the input file is not a multiple of 4, empty pages get inserted.
The inserted pages have the same size as the first page.

Order of pages in the output:

- last page
- first page
- second page
- second-last page
- third-last page
- third page
- fourth page
- ...

## Build from source

There are no extra requirements except Xcode. To build from command line simply run `xcodebuild`
in the project root folder.

## Installing

- Copy the `pdfbooklet` executable to /usr/local/bin/
- Copy the `pdfbooklet.1` man page to /usr/local/share/man/man1/

Alternatively you can also invoke `xcodebuild install DSTROOT=/` to build and install the executable
in one step. This does not install the man page.
