# Option 1: https://stackoverflow.com/questions/20481225/how-can-i-use-a-local-image-as-the-base-image-with-a-dockerfile
# Option 2: https://stackoverflow.com/questions/44166971/pulling-from-a-local-docker-image-instead
#
# Right now I chose option 2
FROM local-amazonlinux:2 AS buildstage0
# FROM local-amazonlinux:2023

# Download all necessary packages
# eventually!
# https://serverfault.com/questions/868600/can-i-install-a-recent-gcc-from-binaries-on-amazon-linux
RUN yum install -y sudo 
RUN yum update -y && \
    yum groupinstall 'Development Tools' -y && \
    yum -y install gcc openssl-devel bzip2-devel libffi-devel wget tar which

# https://techviewleo.com/how-to-install-python-on-amazon-linux/
# https://stackoverflow.com/questions/66255730/python3-8-devel-package-for-amazon-linux
RUN sudo amazon-linux-extras enable python3.8
# RUN sudo yum install -y python3.8-dev
# RUN sudo yum install -y python38-devel.x86_64
RUN yum install -y python38 python38-devel

# Set Up Bazel
FROM buildstage0 as buildstage1
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.8.1/bazelisk-linux-amd64
RUN chmod +x bazelisk-linux-amd64
RUN sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel

# Pull visqol repo
RUN git clone https://github.com/google/visqol.git

# Now we change the working directory!
WORKDIR /visqol

# Copy adapted file_path.h to container
# [1] https://stackoverflow.com/questions/55474690/stdfilesystem-has-not-been-declared-after-including-experimental-filesystem
# [2] https://stackoverflow.com/questions/45867379/why-does-gcc-not-seem-to-have-the-filesystem-standard-library
# [3] https://dev.to/0xbf/how-to-get-glibc-version-c-lang-26he
FROM buildstage1 as buildstage2
COPY file_path.h src/include/
COPY .bazelrc /visqol
COPY setup.py /visqol
COPY test.py /visqol
COPY callee-dump-2023-04-04-09-42-51-dec.wav /visqol
COPY caller-dump-2023-04-04-09-42-51-enc.wav /visqol

# FROM buildstage2 as buildstage3
# RUN python3.8 -m venv env 
# RUN source env/bin/activate 
# RUN python3.8 -m pip install numpy scipy protobuf wheel

# Currently encountering an error, maybe I can salvage something from this github post:
# [1] .. https://github.com/google/mediapipe/issues/1083
# [2] .. https://github.com/google/mediapipe/issues/4059
# [3] .. https://stackoverflow.com/questions/73974753/undefined-reference-to-stdfilesystem-using-bazel-build
# CMD bazel build :visqol -c opt --action_env PYTHON_BIN_PATH="/usr/bin/python3.8" --define=no_tensorflow_py_deps=true
# RUN python3.8 -m pip install .
#
# 1.) ---------------------------------------------------------------------------------------------------------------------------
# The following command comes pretty handy
# see, https://www.ev3dev.org/docs/tutorials/using-docker-to-cross-compile/
# docker run --rm -it -w /visqol local-amazonlinux
#
# --rm ... removes the container after we are done
# --it ... == -i -t, interactive” and “tty”. This will let us use the 
#      command prompt inside of the container.
#   -w ... is the working directory inside of the container.
#
# 2.) ---------------------------------------------------------------------------------------------------------------------------
# The following commands come pretty handy
# find /usr/ -name libstdc++fs.
# find /lib/ -name libc.so
# 
# For redhat distros
# find /lib64/ -name libc.so