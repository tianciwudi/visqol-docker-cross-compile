# Pull docker image and tag it 
docker pull amazonlinux:2 && docker tag amazonlinux:2 local-amazonlinux:2

# Build Docker image
docker build --tag="local-amazonlinux:latest" .

# Capture the container ID
CONTAINER_ID=$(docker run -it local-amazonlinux:latest)

# Copy visqol build folder to working directory
docker cp $CONTAINER_ID:/visqol/build/lib/visqol/ ./build/ 