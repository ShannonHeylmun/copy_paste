#!/bin/bash

set -e

BUILD_DIRECTORY="build/web"
DEPLOY_DIRECTORY="docs"
COMMIT_MESSAGE="Deploy On Pages"
BASE_HREF="/copy_paste/"

build_flutter_web() {
echo "Building Web application..."

    rm -rf "$BUILD_DIRECTORY"
    
    if ! flutter build web \
        --base-href=$BASE_HREF \
		--wasm \
        --release \
		--no-tree-shake-icons; then
        echo "Flutter build failed"
        exit 1
    fi

}

deploy_to_pages() {
echo "Deploying to GitHub Pages..."

    mkdir -p "$DEPLOY_DIRECTORY"
    
    rm -rf "${DEPLOY_DIRECTORY:?}/"*
    
    if ! cp -r "$BUILD_DIRECTORY"/* "$DEPLOY_DIRECTORY"; then
        echo "Failed to copy build files"
        exit 1
    fi

    if git add .; then
        git commit -m "$COMMIT_MESSAGE" && git push
    else
        echo "Git operations failed"
        exit 1
    fi
    
    echo "Deployment completed successfully!"
    echo "Please ensure GitHub Pages is configured to serve from the $DEPLOY_DIRECTORY folder"

}

build_flutter_web
deploy_to_pages