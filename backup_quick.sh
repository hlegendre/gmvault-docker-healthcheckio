#!/bin/bash

if [[ -n "${GMVAULT_HEALTHCHECKSIO_UUID}" ]]; then
  function onfail() {
    echo "Sync interrupted or in error"
    # signal fail
    curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${GMVAULT_HEALTHCHECKSIO_UUID}/fail"
    exit 1
  }

  # on error, run onfail()
  set -eE
  trap onfail ERR SIGINT SIGTERM

  # signal start
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${GMVAULT_HEALTHCHECKSIO_UUID}/start"
fi

echo "Starting quick sync of $GMVAULT_EMAIL_ADDRESS."

gmvault sync -t quick -d /data $GMVAULT_OPTIONS $GMVAULT_EMAIL_ADDRESS 2>&1 | tee /data/${GMVAULT_EMAIL_ADDRESS}_quick.log

if [[ -n "${GMVAULT_SEND_REPORTS_TO}" ]]; then
  echo "Report is sent to $GMVAULT_SEND_REPORTS_TO."
  cat /data/${GMVAULT_EMAIL_ADDRESS}_quick.log | mail -s "Mail Backup (quick) | $GMVAULT_EMAIL_ADDRESS | `date +'%Y-%m-%d %r %Z'`" $GMVAULT_SEND_REPORTS_TO
fi

if [[ -n "${GMVAULT_HEALTHCHECKSIO_UUID}" ]]; then
  # signal success
  curl -fsS -m 10 --retry 5 -o /dev/null --data-raw "$(tail -c 100000 /data/${GMVAULT_EMAIL_ADDRESS}_quick.log)" "https://hc-ping.com/${GMVAULT_HEALTHCHECKSIO_UUID}"
fi

echo "Quick sync complete."
