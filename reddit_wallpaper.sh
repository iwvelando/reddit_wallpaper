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

		suffix=0
		for link in $rssurls
		do
			# Wget the image and give it a 1 minute timeout and another minute for a kill
			timeout -k 60 60 wget -O $scratchdir'/img_'$suffix'.jpg' $link
			((suffix++)) #Increment the suffix
		done

		# For the image grid, set the number of horizontal partitions and then compute the appropriate number of vertical partitions based on that
		hPar=4
		vPar=$( echo "($suffix+$hPar-1)/$hPar" | bc ) # This is just ceil(suffix/hPar)

		# Compute the appropriate dimensions of each image in the grid
		imgWidth=$( echo "$monWidth/$hPar" | bc )
		imgHeight=$( echo "$monHeight/$vPar" | bc )

		# Use imagemagick to resize the images to fit into the grid; you may use the commented convert command (with the !) to ignore aspect ratio during resize; this will forcibly stretch images to fill up the entire grid but may seriously distort some images
		#convert $scratchdir/*.jpg -resize $imgWidth'x'$imgHeight!  $scratchdir/converted.png
		convert $scratchdir/*.jpg -resize $imgWidth'x'$imgHeight  $scratchdir/converted.png

		# Use imagemagick to stitch the images together in a grid; you may use the commented montage command to use a transparent background (or change to a solid color) rather than a texture (background image)
		#montage $scratchdir/converted*.png -background none -mode concatenate -tile $hPar'x'$vPar  $scratchdir/montage.png
		montage $scratchdir/converted*.png -texture $background -mode concatenate -tile $hPar'x'$vPar  $scratchdir/montage.png

		# Toss the finished wallpaper in walldir
		mv $scratchdir/montage.png $walldir/reddit_wallpaper_$subreddit.png

		# Clean the scratch directory before the next round
		rm $scratchdir/*.jpg $scratchdir/*.png

	done

	# Be kind to imgur's servers...
	sleep $update

done
