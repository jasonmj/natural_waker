#!/bin/bash
cd /root/ui
npm run deploy --prefix assets
mix deps.get --only prod
mix phx.digest
exit 0
