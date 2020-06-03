#!/bin/sh
echo "Starting deployment." `date '+%y/%m/%d %H:%M:%S'`

TEMP_PATH="$REPO_HOME/temp"
TEMP_GOPATH="$TEMP_PATH/deploy"
TARGET_PATH="$TEMP_GOPATH/src"
PROJECT="mmorito-leo"  # デプロイ先のプロジェクトID
VERSION=develop # デプロイ先のバージョン名
if [ -x "`which git `" ]; then
    VERSION=`git rev-parse --abbrev-ref HEAD` ||exit  # gitのブランチ名をバージョン名にセット
    VERSION=`echo $VERSION | sed "s/.*\///g"` # フォルダ(feature/)を削除する
    VERSION=`echo $VERSION | sed "s/#*_*//g"` # VERSION名で禁止文字(#と_)を削除する
fi

for OPT in "$@"
do
    case "$OPT" in
        '-p'|'--project')
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "「$1」の引数がありません" 1>&2
                exit 1
            fi
            PROJECT="$2"
            shift 2
            ;;
        '-v'|'--version')
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "「$1」の引数がありません" 1>&2
                exit 1
            fi
            VERSION="$2"
            shift 2
            ;;
    esac
done
if [ -z "$PROJECT" ]; then
    echo "-p または --projectでプロジェクトIDを指定してください" 1>&2
    exit 1
fi

rm -rf $TEMP_PATH
mkdir -p $TARGET_PATH

# Build client
cd $REPO_HOME/front/
npm install
npm run build

# Copy client modules to temp directory
cp -R dist/* $TARGET_PATH

# Copy server modules to temp directory
cd $REPO_HOME/server/
cp -R ./service_main/. $TARGET_PATH
cp -R ./src $TARGET_PATH
cp -R ./go.mod $TARGET_PATH

# index.htmlを動的に扱うためtemplatesに移動
mv "$TARGET_PATH/index.html" "$TARGET_PATH/templates"

# deployment
gcloud app deploy --quiet --no-promote "$TARGET_PATH/app.yaml" --project=$PROJECT --version=$VERSION

rm -rf $TEMP_PATH

echo "Completed deployment." `date '+%y/%m/%d %H:%M:%S'`
