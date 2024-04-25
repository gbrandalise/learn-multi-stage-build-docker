#!/bin/bash

export BUILD_TARGET=${1:-application}

docker compose build