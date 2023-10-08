# Docker Image for GMVault with Healthchecks.io

This is a fork from `aubertg/gmvault-docker` which add support for healthchecks.io signaling (both start and success/failure).

It add a new variable:

- **`GMVAULT_HEALTHCHECKSIO_UUID`** _(optional)_  
  This is the UUID of the healthchecks.io endpoint used for signaling the status of the sync.

## Code Status

[![Docker Automated build](https://img.shields.io/docker/automated/aubertg/gmvault-docker)](https://hub.docker.com/r/aubertg/gmvault-docker/builds/)
[![Docker Pulls](https://img.shields.io/docker/pulls/aubertg/gmvault-docker.svg)](https://hub.docker.com/r/aubertg/gmvault-docker/)

## Overview

A Docker image that runs Gmvault on a regular basis, with both quick (daily) and
full (weekly) synchronization schedules. Emails out sync reports through ssmtp.

```
docker run \
	-v /my/backup/directory:/data \
	-v /my/host/ssmtp.conf:/etc/ssmtp/ssmtp.conf \
	-t \
	-d \
	--name=Gmvault \
	-e GMVAULT_UID=$(id -u myuser) \
	-e GMVAULT_GID=$(id -g mygroup) \
	-e GMVAULT_EMAIL_ADDRESS="myaddress@gmail.com" \
	-e GMVAULT_HEALTHCHECKSIO_UUID="xxx" \
	hlegendre/gmvault-docker-healthcheckio
```

## Running this container for the first time

Gmvault requires authenticated access to the account you want to back up. Due
to Google's new security requirements in order to get access to email data,
you will need to go through the following set up the first time
you run this container:

1. Attach a terminal to your container.
2. Run this command: `gmvault check ${GMVAULT_EMAIL_ADDRESS}`, but do not hit
   ENTER at the prompt, instead hit Ctrl+C. This step will create the
   `gmvault_defaults.conf` in your data directory, but you will need to create a
   custom Google application before you can get an OAuth token.
3. Shut down the container.
4. Follow the instructions
   [here](https://github.com/gaubert/gmvault/issues/335#issuecomment-846483036) to
   create a new client ID and secret. 1. You don't have to do this step with the account you're backing up
   necessarily - as long as you add all the accounts you want to back up as test
   users, this should work correctly. 2. Note the importance of updating `conf_version` depending on the version of
   GMVault that you are running. 3. The last command to run from that list is
   `gmvault check --renew-oauth2-tok ${GMVAULT_EMAIL_ADDRESS}`. You will need to
   start the container again there.
5. To test that GMVault is properly set up, you can run a quick sync with
   `/app/backup_quick.sh`.

## Volumes

The container requires the following volumes to be attached in order to work
properly:

- **`/data`**  
  Where the OAuth token, email backups, and logs will be stored.

- **`/etc/ssmtp/ssmtp.conf`**  
  A ssmtp config file to send emails reports from the Docker container.

  Example for Gmail:

  ```
  # Settings for Gmail SMTP service.
  mailhub=smtp.gmail.com:587
  hostname=smtp.gmail.com:587
  UseSTARTTLS=YES
  FromLineOverride=YES

  # Gmail account.
  root=mygmailaddress@gmail.com
  AuthUser=mygmailaddress@gmail.com
  AuthPass=mypassword
  ```

## Environment Variables

The container is configurable through the following environment variables:

- **`GMVAULT_EMAIL_ADDRESS`** _(required)_  
  The email address of the account to back up.

- **`GMVAULT_HEALTHCHECKSIO_UUID`** _(optional)_  
  The uuid of the healthcheck.io endpoint

- **`GMVAULT_UID`** _(optional)_  
  Numeric uid in the host that should own created files; defaults to 9000.

- **`GMVAULT_GID`** _(optional)_  
  Numeric gid in the host that should own created files; defaults to 9000.

- **`GMVAULT_TIMEZONE`** _(optional)_  
  Timezone; defaults to America/Los_Angeles.

- **`GMVAULT_OPTIONS`** _(optional)_  
  Additional options to pass to gmvault (such as `-c no`).

- **`GMVAULT_QUICK_SYNC_SCHEDULE`** _(optional)_  
  Custom quick sync schedule; defaults to daily.

- **`GMVAULT_FULL_SYNC_SCHEDULE`** _(optional)_  
  Custom full sync schedule; defaults to weekly.

- **`GMVAULT_SYNC_ON_STARTUP`** _(optional)_  
  Set to `yes` to trigger a sync when the container starts, in addition to the
  normal cron schedule.

## Thanks

- Thank you [Hugues Le Gendre](https://github.com/hlegendre) for adding the healthchecks.io integration

- Thank you [Guillaume Aubert](https://github.com/gaubert) for developing
  [Gmvault](https://github.com/gaubert/gmvault)!

- Thank you [Jason Horne](https://github.com/jdhorne) for publishing
  [jdhorne/gmvault-docker](https://github.com/jdhorne/gmvault-docker)! I learned
  a lot from your architecture before building my own image.

## Copyright

Copyright (C) 2017-2021 Guillaume Aubert.
Copyright (C) 2023 Hugues Le Gendre ?

## License

This software is released under the MIT license. See the LICENSE file for
details.

## Disclaimer

I am providing code in this repository to you under an open source license.
Because this is my personal repository, the license you receive to my code is
from me and not from my employer (Facebook).
