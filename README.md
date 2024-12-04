# Plex helper scripts

## Monitor Directory for new media and notify Plex to partial scan that media folder
1. plex_monitor_tube.sh  - Used to monitor the folder and log new media files being added.  Run this script all the time.
2. plex_monitor.sh - Used to query the log file and notify Plex to scan folders found in the log.  Put this script on a CRON shedule.  I.e. every 10 minutes.

Todo:
- Improve Error Handling
- Improve Logging notifications
