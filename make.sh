#!/bin/bash

set -e

root=$(cd $(dirname $0); pwd)

clean() {
    rm -rf $root/node_modules
    rm -rf $root/website/demo/node_modules
}

install() {
    cd $root

    if [ ! -f "./node_modules/.bin/uglifyjs" ]; then
        npm install uglifyjs
    fi

    ./node_modules/.bin/uglifyjs \
        angular-async-loader.js -c -m \
        -o angular-async-loader.min.js \
        --source-map angular-async-loader.min.js.map


    cd $root/website/demo

    if [ ! -d "./node_modules" ]; then
        npm install

        mkdir -p assets/requirejs/
        cp node_modules/requirejs/require.js assets/requirejs/

        mkdir -p assets/angular/
        cp node_modules/angular/angular.min.js assets/angular/

        mkdir -p assets/angular-ui-router/release/
        cp node_modules/angular-ui-router/release/angular-ui-router.min.js assets/angular-ui-router/release/

        mkdir -p assets/angular-ui-mask/dist/
        cp node_modules/angular-ui-mask/dist/mask.min.js assets/angular-ui-mask/dist/

        mkdir -p assets/ng-tags-input/build/
        cp node_modules/ng-tags-input/build/ng-tags-input.min.js assets/ng-tags-input/build/
        cp node_modules/ng-tags-input/build/ng-tags-input.min.css assets/ng-tags-input/build/

        mkdir -p assets/ng-file-upload/dist/
        cp node_modules/ng-file-upload/dist/ng-file-upload-all.min.js assets/ng-file-upload/dist/
    fi

    mkdir -p assets/angular-async-loader/
    cp $root/angular-async-loader.min.js assets/angular-async-loader/
}

build_website() {
    cd $root
    git branch -D gh-pages || true
    git checkout --orphan gh-pages

    mv ./website /tmp/
    git reset --hard
    mv /tmp/website/* ./
    git add --all
    git commit -m "Update website"

    git checkout master
}

test() {
    cd $root

    if [ ! -f "./node_modules/.bin/browser-sync" ]; then
        npm install browser-sync
    fi

    ./node_modules/.bin/browser-sync start -s website/demo --files website/demo
}

case "$1" in
    clean)
        clean
        ;;
    install)
        install
        ;;
    website)
        build_website
        ;;
    test)
        test
        ;;
    *)
        echo "Usage: $0 { clean | install | test }"
        exit 1
esac

