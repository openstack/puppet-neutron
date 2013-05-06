#!/bin/bash
# This example script shows how to create a simple subnet for Quantum.

source /root/openrc
quantum net-create mynet
quantum subnet-create --name mynet-subnet mynet 10.0.0.0/24
quantum router-create myrouter
quantum router-interface-add myrouter mynet-subnet
