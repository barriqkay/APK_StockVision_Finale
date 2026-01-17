#!/bin/bash
export PATH="$PATH:/opt/flutter/bin:$HOME/flutter/bin"
cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app

echo "Starting build at $(date)" > build_log.txt
flutter build apk --debug >> build_log.txt 2>&1
echo "Build finished at $(date)" >> build_log.txt

