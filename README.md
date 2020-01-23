## Multiarch (amd64/i386/armhf/arm64(aarch64)) docker images for UrBackup client.
Pulling the `:latest` tag should automatically grab the right image for your arch.

## Running

### If you want to use docker run command:
```
docker run -d \
                --name urbackup-client \
                -e TZ=Europe/Berlin \
				-e URBACKUP_SERVER_NAME=example.com
				-e URBACKUP_CLIENT_NAME=exampleclientname
				-e URBACKUP_CLIENT_AUTHKEY=secretkey
                -v /path/to/backup:/backup \
                uroni/urbackup-client:latest
```

### Or via docker-compose (compatible with stacks in Portainer): 

`docker-compose.yml`
```
version: '2'

services:
  urbackup:
    image: uroni/urbackup-client:latest
    container_name: urbackup-client
    environment:
      - TZ=Europe/Berlin # Enter your timezone
	  - URBACKUP_SERVER_NAME=example.com
	  - URBACKUP_CLIENT_NAME=exampleclientname
	  - URBACKUP_CLIENT_AUTHKEY=secretkey
    volumes:
      - /path/to/backup:/backup  
```              
	     
## Building locally
Please use the provided `build.sh` script:
```
./build.sh
```
On default the script will build a container for amd64 with the most recent stable version.

To build for other architectures the script accepts following argument:
`./build.sh [ARCH] [VERSION]`

`[ARCH]` can be `amd64`, `i386`, `armhf` or `arm64`; `[Version]` can be an existing version of UrBackup-server

For example if you want to build an image for version 2.4.10 on armhf use the following command:
```
./build.sh armhf 2.4.10
```
