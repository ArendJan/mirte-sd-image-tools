#!/bin/bash
sudo tee /etc/apt/apt.conf.d/99force-ipv4 <<EOF
Acquire::ForceIPv4 "true";
EOF
rm /etc/resolv.conf || true
echo "nameserver 8.8.8.8" >/etc/resolv.conf || true


sudo apt update
sudo apt install -y libsqlite3-dev python3-dev python3-numpy  python3-psutil python3-pytest-timeout libeigen3-dev libbullet-dev graphviz cppcheck liborocos-kdl-dev libzstd-dev libssl-dev google-mock python3-mypy python3-pytest-mock acl libacl1-dev libconsole-bridge-dev pkg-config pydocstyle uncrustify libxml2-utils libasio-dev libtinyxml2-dev libspdlog-dev pybind11-dev libbenchmark-dev libyaml-cpp-dev clang-format python3-lark libgtest-dev libtinyxml-dev libyaml-dev python3-lxml 
