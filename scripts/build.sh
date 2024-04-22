# You can modify this command to build to different platforms (linux x86 or ARM), both have been validated.
# docker buildx bake --no-cache --set \*.platform=linux/arm64
docker buildx bake --no-cache --set \*.platform=linux/amd64