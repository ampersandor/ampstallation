# Spark with Docker-compose
This repository provides Dockerfile and docker-compose.yml file that helps you construct a mock spark cluster with standalone manager. Not only could you experience the client mode with jupyter-lab environment, furthermore you can submit your spark programming through cluster mode to spark://localhost:7077

## Features
Happy test and examine your spark programming!

## Installation
```bash
chmod +x ./build.sh
./build.sh
docker-compose up
```

## Links
- [jupyterlab](http://localhost:9999)
- [masterUI](http://localhost:9090)
- [worer1UI](http://localhost:9091)
- [worer2UI](http://localhost:9092)
- [applicationUI](http://localhost:4040)



## Contributors
- [ampersandor](https://github.com/ampersandor)