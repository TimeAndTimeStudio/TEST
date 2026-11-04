#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$(realpath "$0")")"

JAR_URL="https://raw.githubusercontent.com/TimeAndTimeStudio/TEST/main/server-release.jar"
MAP_URL="https://raw.githubusercontent.com/TimeAndTimeStudio/TEST/main/Time%20Model%202.msav"

mkdir -p config/maps config/saves

for cmd in java curl; do
    command -v "$cmd" >/dev/null || {
        echo "Missing: $cmd"
        exit 1
    }
done

download() {
    local url="$1" file="$2"

    if [[ -s "$file" ]]; then
        echo "Found: $file"
        return
    fi

    curl -fL --retry 3 -o "$file.part" "$url"
    test -s "$file.part"
    mv "$file.part" "$file"
}

download "$JAR_URL" server-release.jar
download "$MAP_URL" "config/maps/Time Model 2.msav"

if [[ -s config/saves/main.msav ]]; then
    START_CMD="load main"
else
    START_CMD="host Time_Model_2 survival"
fi

echo "Starting Mindustry: $START_CMD"

{
    sleep 4
    echo "playerlimit 3"
    echo "config autoPause true"
    echo "config autosave false"

    if [[ "$START_CMD" == host* ]]; then
        echo "reloadmaps"
        sleep 1
    fi

    echo "$START_CMD"
    sleep 2
    echo "status"
    cat /dev/tty

} | java --enable-native-access=ALL-UNNAMED \
    -Xms512m -Xmx4G -jar server-release.jar
