#!/usr/bin/env bash
docker-compose up -d
docker-compose exec nerves mix deps.get
docker-compose exec nerves mix firmware
docker-compose exec nerves mix upload nerves.local
