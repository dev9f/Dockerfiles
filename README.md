# STIGMA Container

STIGMA Container is a monitoring tool to Pysical Server, VirtualMachnie, Cloud infra, etc. using docker containers.
STIGMA is composed of five sub-systems.
* Nagios
* MySQL
* InfluxDB
* Grafana


# To install STIGMA Container

## Prerequisites

Make sure that the following things are installed and available on your system:

* Git.
* The latest Docker Engine. 
  * The best way to do this: go to https://docs.docker.com/engine/installation/ and follow the instructions.
* The latest Docker Compose.
  * The best way to do this: go to https://docs.docker.com/compose/install/ and follow the instructions.


## To use STIGMA Container

The source includes an Dockerfiles for build STIGMA Container images.
After git clone, run the following commands:

`docker-compose -p stigma -f stigma-compose.yml up` 

- This will make build STIGMA Container images and running STIGMA project(five sub-systems).
By the end of this run, you will have running SITGMA Containers(five-subsystems).
And './pvol directory' is created for use STIGMA Container's persistence volume. 

## STIGMA Service check
* SITGMA - http://[docker-engin host] - register 
* nagisos - https://[docker-engin host]:8080/nagios - nagiosadmin:qwe123
* influxdb - https://[docker-engin host]:8083 - root:root or stigma:stigma,database=stigma
* grafana - https://[docker-engin host]:3000 - admin:admin


## Related git repository
* SITGMA2 - https://github.com/stigma2/stigma2-dev

