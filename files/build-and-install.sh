#!/bin/bash

cd $HOME

PATH=/usr/local/node-v16.13.2-linux-x86/bin:/usr/local/go/bin:$PATH

cd src/web/storagenode 
npm install
npm run build
cd ../..
go-bindata -prefix web/storagenode/ -fs -o storagenode/console/consoleassets/bindata.resource.go -pkg consoleassets web/storagenode/dist/... web/storagenode/static/...
/usr/bin/env echo -e '\nfunc init() { FileSystem = AssetFile() }' >> storagenode/console/consoleassets/bindata.resource.go
gofmt -w -s storagenode/console/consoleassets/bindata.resource.go
git checkout .
./scripts/release.sh install ./cmd/storagenode

