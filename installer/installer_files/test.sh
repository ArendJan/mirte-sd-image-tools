#!/bin/bash


test_func() {
    cat ~/Downloads/mirte_orangepizero2.zip
}

test_func2() {
    md5sum
}

test_func | test_func2