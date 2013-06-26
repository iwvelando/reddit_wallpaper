#!/bin/bash

# This script iterates through a preset list of subreddits and uses their imgur rss feeds to extract images from them and arrange them into a grid with imagemagick; the resulting wallpaper can be combined with a slideshow wallpaper style to get a dynamic desktop background. Credit for the original idea goes to /u/Emwat1024. The default wallpaper is available free from http://www.heikotischler.com/?project=wallpaper

# Set your preferred subreddits; scratchdir is a scratch directory for downloading and manipulating images while walldir is where the finished image will be stored and updated periodically
declare -a subreddits=(earthporn wallpaper wallpapers diy itookapicture spaceporn photographs unixporn)
scratchdir=$( mktemp -d --suffix=_reddit_wallpaper ) # Make a unique scratch directory in /tmp
walldir=/media/data/reddit_wallpaper_$USER
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) # Should be the location of this script
background=$scriptdir/background/background1.jpg
update=3600 # Update interval in seconds; default is to update the wallpaper for each subreddit every hour

# If it doesn't already exist, make walldir
if [ ! -d $walldir ]; then mkdir $walldir; fi

# Monitor dimensions (hard-coding until I find a nice way to deal with detecting dual monitors)
monWidth=1920
monHeight=1080

# This sleep is to make sure you have a chance to connect to the internet if you use this as a startup script
sleep 5

while true
do

	for subreddit in ${subreddits[@]}
	do

		# Grab the rss page from imgur
		rss=$( curl http://imgur.com/r/$subreddit/rss )

		# Match the imgur direct links from the rss feed and then trim the &q characters from the end that were used for the matching
		rssurls=$( echo $rss | grep -oP ".{0,1}ttp://i.imgur.{0,13}.jpg&q" | sed 's/..$//' )

		suffix=0 # Suffix for naming the images, also serves to count the images we've pulled
		for link in $rssurls
		do
			# Wget the image and give it a 1 minute timeout and another minute for a kill
			timeout -k 60 60 wget -O $scratchdir'/img_'$suffix'.jpg' $link
			((suffix++)) #Increment the suffix
		done

		# For the image grid, choose the grid layout such that it's as square as possible with the horizontal dimension never being larger than the vertical
		hPar=$( echo "sqrt($suffix)" | bc) # This comes out to be floor(sqrt(suffix))
		vPar=$( echo "($suffix+$hPar-1)/$hPar" | bc ) # This is just ceil(suffix/hPar)

		# Compute the appropriate dimensions of each image in the grid
		imgWidth=$( echo "$monWidth/$hPar" | bc )
		imgHeight=$( echo "$monHeight/$vPar" | bc )

		# Use imagemagick to stitch the images together in a grid; you may use the commented montage command to use a transparent background (or change to a solid color) rather than a texture (background image) and stretch each image in the montage with the ! in the geometry command
		#montage $scratchdir/*.jpg -background none -tile $hPar'x'$vPar -geometry $imgWidth'x'$imgHeight! $walldir/reddit_wallpaper_$subreddit.png
		montage $scratchdir/*.jpg -texture $background -tile $hPar'x'$vPar -geometry $imgWidth'x'$imgHeight $walldir/reddit_wallpaper_$subreddit.png

		# Clean the scratch directory before the next round
		rm $scratchdir/*.jpg

	done

	# Be kind to imgur's servers...
	sleep $update

done
