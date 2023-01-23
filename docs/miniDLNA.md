# miniDLNA Icon
**Create a custom icon for your server**

Clone the repository for miniDLNA since it must be built from source if you want a custom icon.

`git clone git://git.code.sf.net/p/minidlna/git minidlna-git`

Create a directory for your icons, you need 4 copies of the icon in 2 sizes and 2 formats.

`large = 102H x 120W`
`small = 48H x 41W`

**The naming convention is important for the script to run successfully.**

```
png_sm.png
png_lrg.png
jpeg_sm.jpg
jpeg_lrg.jpg
```

User [hiero](https://sourceforge.net/p/minidlna/discussion/879956/thread/cc0ccac8/#9b1d) over on SourceForge posted a simple `C` program to convert the images to the proper hex values.

Create a `conversion.c` file in your icon directory.

```
/* convert icon data for icons.c" */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char *argv[])
{
    int i, c;
    FILE *rfp, *wfp;
    if (argc < 3) {fprintf(stderr, "Usage: %s inputfilename outputfilename\n\n", argv[0]); exit(1);}
    rfp = fopen (argv[1], "rb");
    if (rfp == NULL) {fprintf(stderr, "cannot open \"%s\"\n", argv[1]); exit(1);}
    wfp = fopen (argv[2], "wb");
    if (wfp == NULL) {fprintf(stderr, "cannot create  \"%s\"e\n", argv[2]); exit(1);}
    for (; ;) {
        fprintf(wfp, "             \"");
        for (i=0; i<24 ; i++) {
            c = fgetc(rfp); if (c == EOF) break;
            c = fprintf(wfp, "\\x%02x", c); if (c<0) goto end;
        }
        fprintf(wfp, "\"\n");
        if (c == EOF) break;
    }
end:
    fclose(rfp);
    fclose(wfp);
    exit(0);
}
```

Compile your C program `gcc conversion.c`.

In the same directory as the images and your new `C` program, make a shell script.

`convert-images.sh`

```
#!/bin/bash

./a.out jpeg_lrg.jpg jpeg_lrg.jpg.hex
./a.out jpeg_sm.jpg jpeg_sm.jpg.hex
./a.out png_lrg.png png_lrg.png.hex
./a.out png_sm.png png_sm.png.hex
```

Copy and paste the content from the .hex output of each file and replace the original in the `icons.c` file that resides in the the cloned miniDLNA folder.

## Recompile miniDLNA

```
.autogen.sh

./configure

make

sudo make install
(there is a recommendation to use `sudo checkinstall` instead.)

```

[Helpful page](https://www.smarthomebeginner.com/install-minidlna-on-ubuntu-ultimate-guide/#Download_MiniDLNA)
