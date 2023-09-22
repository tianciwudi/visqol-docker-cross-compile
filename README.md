# Introduction
This document describes on how one can set-up a Docker environment to cross-compile VISQOL for Amazon Lambda respectively Amazon Linux 2.

## Setting Up Amazon Linux Image
To pull the image, just paste `docker pull amazonlinux:2` to the command line. To make sure, that we don’t download the image each time we build the container paste `docker tag amazonlinux:2 local-amazonlinux:2`. Now we can build from the local image. 

## Building the image
To build the image, paste `docker build --tag="local-amazonlinux:latest" .`  to the command line. You could also paste `docker build .`, I just provided a new tag for versioning.

## Run the image
To run the image paste `docker run -it local-amazonlinux:latest` to the command line. This opens an interactive session. **Important:** Make sure you delete the container after you copied all necessary files from the container image  to your host system.

## Inside the container

After you have started the interactive session within the container, just paste the following lines to the command line in the exact same order

```Shell
python3.8 -m venv env
source env/bin/activate
python3.8 -m pip install numpy scipy protobuf wheel
bazel build :visqol -c opt
python3.8 -m pip install .
```

After that, we just have to copy `visqol_lib_py.so` to the host system via `docker cp name-of-the-currently-running-container:/visqol/build/lib/visqol/ ./build/ ` For that, open a second terminal window or kill the currently running container and then copy everything to get the container name. To get the container name, paste `docker ps -a` or `docker ps` to the command line.

## Setting Up Folder structure

Before we try to build https://github.com/google/visqol, we have to setup our project.  Just make a new folder and change into  the new working directory, for example `path\to\visqol-docker-cross-compile-folder\`. In this new directory the following files should be there, namely 
- `.bazelrc`
- `Dockerfile`
- `file_path.h`
- `setup.py` 
- `test.py`

Additionally, to test, if we can calculate the MOS Score in the Docker environment via VISQOL, we provide two audio files: callee.wav ('degraded' audio) and caller.wav ('reference' audio). The next sub sections  describe the content of each file.  Just copy them into your folder!

## Important Notes:
The reason why I invoked the bazel build commands receptively the python3.8 commands manually inside the container was just for debugging purposes. You could definitely automate everything! I just wanted to make sure that I have control over each step in the building process.

## Update 20.09.2023
If you run the script `invoke.sh`, then the complete building process will be executed automatically.