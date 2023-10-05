ARG debian_buster_image_tag=11-jre-slim

FROM openjdk:${debian_buster_image_tag}
ARG shared_workspace=/opt/workspace

RUN apt-get update && apt-get install -y curl vim wget ssh net-tools ca-certificates python3 python3-pip

RUN mkdir -p ${shared_workspace} && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

VOLUME ${shared_workspace}
ENV SHARED_WORKSPACE=${shared_workspace}
CMD ["bash"]
