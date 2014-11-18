#!/bin/bash

luajit pack.lua ../
luajit -b singleFile.lua main.lua
