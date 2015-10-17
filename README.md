# ooi2docker
docker build files for ooi

## Installation

Install docker and clone this repository

    apt-get install docker
    git clone https://github.com/Laforeta/ooi2docker.git
    cd ooi2docker

Edit ooi_nginx.conf, replace server_name with your domain name or public IP address for both http and https site

Build Docker Image

    docker build -t ooi .
    docker run -d -p 80:80 -p 443:443 ooi
