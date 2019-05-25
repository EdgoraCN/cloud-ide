#!/bin/bash

/usr/local/bin/onedrive --confdir=~/onedrive --syncdir=~/OneDrive --verbose=true
cp ~/onedrive/refresh_token $IDE_WORKSPACE/.vscode/onedrive/refresh_token