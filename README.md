# reddit_wallpaper

## Requirements

imagemagick and bc need to be installed

    apt-get install imagemagick bc

## Install

Clone:

    git clone git://github.com/iwvelando/reddit_wallpaper.git

You'll need to edit reddit_wallpaper/reddit_wallpaper.sh to suit your own system:

(Likely) required changes:
- Line 8: Change walldir to the directory where you want the finished wallpapers to be moved to
- Line 7: If you're not allowed to or don't want to write to /tmp you'll also need to change scratchdir; this is where images will be pulled, manipulated, and combined before being moved to walldir.
- Lines 17,18: Specify the desired wallpaper resolution which is probably your monitor resolution.

Now you can simply execute reddit_wallpaper/reddit_wallpaper.sh either from a terminal or just by clicking it in your favorite file manager. The finished wallpapers should appear in walldir (as set in the script).

## Usage and Customization

- Line 6: List of subreddits the wallpapers will be created from
- Line 10: (Optionally) set the background image for the wallpapers if there is any empty space leftover after the images have been combined
- Line 11: Refresh interval in seconds; this is how frequently you query imgur for these subreddits and update the wallpapers
- Line 52: You can use this line instead of line 53 to use either a transparent background or a solid color background and to force-stretch each image to fit flush in the grid
