# Photo manager for Windows

This script orders photos based on their modification date: a .jpg photo dating from the 1st december 2018 8:36 AM will be put in a folder called 2018.12 (yyyy.mm), and will be renamed 01-08h36m.jpg.

If two files have the same date, the script compares these files. If they are duplicates then the script keeps just one of these files. Else a suffix is added to the end of the filename (01-08h36m.jpg, 01-08h36m_1.jpg, 01-08h36m_2.jpg, ...).

## How it works
- Put the photo_manager.bat file in a folder.
- Put all your photos to be ordered in the same folder. Note: files should not have an exclamation mark (!) in their names or else they won't be ordered.
- Double-click photo_manager.bat.
- Wait for the script to finish ordering your photos. First all your files are moved in a backup folder for safety measures. Then they are copied from the backup folder in a folder based on their modification date.
