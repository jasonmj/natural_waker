#!/usr/bin/env bash
docker-compose up -d
docker-compose exec nerves mix upload.hotswap
