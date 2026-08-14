#!/bin/bash
# xlsx 원본이 SeedData.json보다 최신이면 convert_seed.py를 자동 실행해 재생성한다.
# Xcode 빌드 전(prebuildScripts)에 실행되도록 project.yml에 등록되어 있다.

set -e

export PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:$PATH"

XLSX_PATH="${SRCROOT}/../페퍼톤스_공연DB.xlsx"
JSON_PATH="${SRCROOT}/Sources/App/SeedData.json"
CONVERT_SCRIPT="${SRCROOT}/Scripts/convert_seed.py"

if [ ! -f "$XLSX_PATH" ]; then
    echo "warning: 원본 엑셀(${XLSX_PATH})을 찾을 수 없어 SeedData.json 재생성을 건너뜁니다."
    exit 0
fi

if [ ! -f "$JSON_PATH" ] || [ "$XLSX_PATH" -nt "$JSON_PATH" ]; then
    echo "SeedData.json이 오래되어 재생성합니다..."
    if python3 "$CONVERT_SCRIPT" "$XLSX_PATH" "$JSON_PATH"; then
        echo "SeedData.json 재생성 완료."
    else
        echo "warning: SeedData.json 재생성 실패 - 기존 파일을 그대로 사용합니다."
    fi
else
    echo "SeedData.json이 최신 상태입니다."
fi
