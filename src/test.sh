#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
