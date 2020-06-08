#!/usr/bin/env bash

find . -iname "*.r" | entr -r Rscript run.R
