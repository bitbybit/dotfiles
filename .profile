if [ -n "$DISPLAY" ]; then
     BROWSER=chromium
fi

synclient HorizEdgeScroll=1 HorizTwoFingerScroll=1 VertEdgeScroll=1
syndaemon -t -k -i 2 -d
