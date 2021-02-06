#!/run/current-system/sw/bin/sh

docker-compose up -d

case $1 in
    "burn")
        docker-compose exec nerves mix deps.get
        docker-compose exec nerves mix firmware.burn
        ;;

    "hotswap")
        docker-compose exec nerves mix upload.hotswap
        ;;

    "update")
        docker-compose exec nerves mix deps.get
        docker-compose exec nerves mix firmware
        docker-compose exec nerves mix upload 192.168.0.101 #nerves-waker.local
        ;;
esac

exit 0
