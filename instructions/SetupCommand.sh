#!/bin/bash

#===================================================================================================================
# Running Ubuntu on Windows WSL Related
#===================================================================================================================
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




#===================================================================================================================
# Git Related
#===================================================================================================================
git init
git remote -v
git remote add origin https://github.com/faijurrahman/freqtrade.git
git config --global user.email "faijur@gmail.com"
git config --global user.name "Faijur Rahman"




#===================================================================================================================
# Setup FreqTrade Related
#===================================================================================================================
# The installation commands are takend from here: https://youtu.be/VHvikJmQrVM
# Install pre-requisite packages for freqtrade
sudo apt-get update
sudo apt-get install python3
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y python3-dev
sudo apt install -y python3-pandas

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
# Please check here for all commands: https://www.freqtrade.io/en/stable/utils/




#===================================================================================================================
# Preparing the Initial Environment of FreqTrade Related
#===================================================================================================================
# Create user_data & config.json and then update followings:
# Details of config can be found here: https://www.freqtrade.io/en/stable/configuration/
freqtrade create-userdir --userdir user_data
freqtrade new-config --config config.json
# Update config.json: exchange->pair_whitelist: ["BTC/USDT", "ETH/USDT"]
# Update config.json: pairlists->method: "StaticPairList",
# Please follow the video tutorial for more details: https://youtu.be/VHvikJmQrVM

# Some Usefull command for git
git status
git log
git diff config.json
git add -f config.json
git commit -m "Adding default config.json"
git pull --rebase
git push

# Make the local modification config.json untracked to avoid accidentally submitting sensitive account infos
git update-index --skip-worktree config.json
git update-index --skip-worktree live_config.json




#===================================================================================================================
# Prepare environment, WebUI, Telegram, Database etc.
#===================================================================================================================
# Setup env variable for Telegram and Exchange
# Details here: https://www.freqtrade.io/en/latest/configuration/#environment-variables
# export FREQTRADE__TELEGRAM__CHAT_ID <telegramchatid>  # Please check here: https://www.freqtrade.io/en/latest/telegram-usage/
# export FREQTRADE__TELEGRAM__TOKEN <telegramToken>
# export FREQTRADE__EXCHANGE__KEY <yourExchangeKey>
# export FREQTRADE__EXCHANGE__SECRET <yourExchangeSecret>
source .env/freqtrade.env

# Details help of WebUI here: https://www.freqtrade.io/en/stable/rest-api
freqtrade install-ui # Need to run only once


#===================================================================================================================
# UserDir and Strategy Generation Command Related
#===================================================================================================================
freqtrade new-strategy --help
freqtrade new-strategy --template minimal --userdir . --strategy faijur_minimal
freqtrade new-strategy --template full --userdir . --strategy faijur_full
freqtrade new-strategy --template advanced --userdir . --strategy faijur_advanced



#===================================================================================================================
# Trade Command Related
#===================================================================================================================
# Start Trading but in dryrun only to test the WebUI
freqtrade trade --config config.json --strategy SampleStrategy -vv
freqtrade trade --config config.json --strategy ReinforcedSmoothScalp --strategy-path user_data/strategies/berlinguyinca -vv
# From browser go to page: http://127.0.0.1:8080/

# Start trading in live mode.
# Details manual of live trading here: https://www.freqtrade.io/en/stable/bot-usage/
freqtrade trade --config live_config.json --strategy ReinforcedSmoothScalp --strategy-path user_data/strategies/berlinguyinca -vv


# Investigating old trades
freqtrade show-trades --db-url sqlite:///tradesv3.dryrun.sqlite




#===================================================================================================================
# FreqAI Trade Related
#===================================================================================================================
# Details document here: https://www.freqtrade.io/en/stable/freqai
freqtrade trade --config config_examples/config_freqai.example.json --strategy FreqaiExampleStrategy --freqaimodel LightGBMRegressor --strategy-path freqtrade/templates

# Running FreqAI: https://www.freqtrade.io/en/stable/freqai-running
freqtrade trade  --config config_examples/config_freqai.example.json --strategy FreqaiExampleStrategy --freqaimodel LightGBMRegressor --strategy-path freqtrade/templates
freqtrade backtesting  --config config_examples/config_freqai.example.json --strategy FreqaiExampleStrategy --freqaimodel LightGBMRegressor --strategy-path freqtrade/templates --timerange 20210501-20210701

# Reinforcement Learning: https://www.freqtrade.io/en/stable/freqai-reinforcement-learning
freqtrade trade --config config.json --strategy MyRLStrategy --freqaimodel ReinforcementLearner 




#===================================================================================================================
# Backtesting Related
#===================================================================================================================
# Before backtesting we need to download data for target timeframse
# Download data with the following command
freqtrade list-timeframes
freqtrade download-data --config config.json --days 999 -t 5m 15m 30m 1h 2h 4h 1d 1w
# The data will be in user_dat/data/binance folder
freqtrade list-data

# Backtesting with WebUI
freqtrade webserver --config config.json

# Backtesting the data. Details document of Backtesting: https://www.freqtrade.io/en/stable/backtesting/
freqtrade backtesting --config config.json --strategy SampleStrategy -vv
freqtrade backtesting --config config.json --strategy SampleStrategy --timerange=20210101-20211001 -vv
freqtrade backtesting --config config.json --strategy SampleStrategy --timerange=20210101-20211001 --timeframe=4h -vv
freqtrade backtesting-show ??

# https://www.freqtrade.io/en/stable/advanced-backtesting/#analyze-the-buyentry-and-sellexit-tags
freqtrade backtesting-analysis --config config.json --analysis-groups 0 1 2 3 4




#===================================================================================================================
# Hyperparameter Optimization Related
#===================================================================================================================
# Details here: https:https:
#      //www.freqtrade.io/en/stable/hyperopt 
#      //www.freqtrade.io/en/stable/utils
freqtrade hyperopt-list 
freqtrade hyperopt-list --profitable --no-details 
freqtrade hyperopt-show -n 168
freqtrade hyperopt-show --best -n -1 --print-json --no-header

