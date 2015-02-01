# this file controls the product announcement placeholder on the dashboard page
# How to use :
# 1- set a unique name for the announcement, in the ANNOUNCEMENT_CODE constant, eg: 'video_players'
# 2- paste the link to the blog article in the ANNOUNCEMENT_URL constant, eg: 'http://blog.contentbird.com/articles/video-players'
# 3- edit config/locales/announcements/fr.yml and en.yml and create a new key with the name matching your ANNOUNCEMENT_CODE
# 4- test it on your localhost
# 5- deploy it on cb-dev, and test it
# your are ready to mep

ANNOUNCEMENT_CODE = 'mail_channel'
# to test: ANNOUNCEMENT_CODE = 'test_announcement'

ANNOUNCEMENT_URL  = 'http://blog.contentbird.com/articles/nouveau-sur-contentbird-le-canal-email'
# to test: ANNOUNCEMENT_URL = 'http://google.com'
