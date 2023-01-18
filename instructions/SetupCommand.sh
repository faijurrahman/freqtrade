#!/bin/bash

# Please following this guide to prepare Ubuntu in windows WSL
# Guide: https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps

# Step1: Related commands in Power shell
# wsl --update
# wsl --shutdown

# Step2: Then ubuntu commands to install all necessary packages
# sudo apt update
# sudo apt install gedit -y
# sudo apt install gimp -y
# sudo apt install nautilus -y
# sudo apt install x11-apps -y
# sudo apt install geany -y

# Step 3: To install the Google Chrome for Linux:
# Change directories into the temp folder: cd /tmp
# Use wget to download it: sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# Get the current stable version: sudo dpkg -i google-chrome-stable_current_amd64.deb
# Fix the package: sudo apt install --fix-broken -y
# Configure the package: sudo dpkg -i google-chrome-stable_current_amd64.deb
# To launch, enter: google-chrome

# The installation commands are takend from here: https://youtu.be/VHvikJmQrVM
# Install pre-requisite packages for freqtrade
sudo apt-get update
sudo apt-get install python3
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y python3-dev
sudo apt install -y python3-pandas

# Configure git
git init
git remote -v
git remote add origin https://github.com/faijurrahman/freqtrade.git
git config --global user.email "faijur@gmail.com"
git config --global user.name "Faijur Rahman"

# Download stable source code from github
# git clone https://github.com/freqtrade/freqtrade.git (Original)
#cd freqtrade
#git checkout stable
git clone https://github.com/faijurrahman/freqtrade.git
cd freqtrade


# Setup the freqtrade binaries
./setup.sh -i

# Activate venv. Use this command every time you restart Ubuntu
source ./.env/bin/activate
freqtrade --help

# Create user_data & config.json and then update followings:
# Details of config can be found here: https://www.freqtrade.io/en/stable/configuration/
freqtrade create-userdir --userdir user_data
freqtrade new-config --config config.json
# Update config.json: exchange->pair_whitelist: ["BTC/USDT", "ETH/USDT"]
# Update config.json: pairlists->method: "StaticPairList",
# Please follow the video tutorial for more details: https://youtu.be/VHvikJmQrVM
git add -f config.json
git commit -m "Adding default config.json"
git pull
git push


# Download data with the following command
freqtrade list-timeframes
freqtrade download-data --config config.json --days 999 -t 5m 15m 30m 1h 2h 4h 1d 1w
# The data will be in user_dat/data/binance folder
freqtrade list-data


# Backtesting the data. Details document of Backtesting: https://www.freqtrade.io/en/stable/backtesting/
freqtrade backtesting --config config.json --strategy SampleStrategy
freqtrade backtesting --config config.json --strategy SampleStrategy --timerange=20210101-20211001
freqtrade backtesting --config config.json --strategy SampleStrategy --timerange=20210101-20211001 --timeframe=4h



# Start Trading but in dryrun only to test the WebUI
# Details help of WebUI here: https://www.freqtrade.io/en/stable/rest-api
freqtrade install-ui
freqtrade trade --config config.json --strategy SampleStrategy
freqtrade trade --config config.json --strategy ReinforcedSmoothScalp --strategy-path user_data/strategies/berlinguyinca
# From browser go to page: http://127.0.0.1:8080/

# Start trading in live mode.
# Details manual of live trading here: https://www.freqtrade.io/en/stable/bot-usage/
freqtrade trade --config config.json --strategy ReinforcedSmoothScalp --strategy-path user_data/strategies/berlinguyinca
