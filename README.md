# Plex helper scripts

## Monitor Directory for new media and notify Plex to partial scan that media folder
1. plex_monitor_tube.sh  - Used to monitor the folder and log new media files being added.  Run this script all the time.
2. plex_monitor.sh - Used to query the log file and notify Plex to scan folders found in the log.  Put this script on a CRON shedule.  I.e. every 10 minutes.

Limitations:
- only handles 1 library at a time.  But you can run more than one script.  I suggest seperate log files, if you do.
- If you're adding thousands of files, then disable the script until after your bulk add.

Todo:
- Improve Error Handling
- Improve Logging notifications
- Make more robust.  Currently the script could miss an update if a new file is added between API call, plex confirmation and removing the log entry.  May change this up to use timestamps and then prune the log.  But right now this is pretty rare, so not a high priority for me.
