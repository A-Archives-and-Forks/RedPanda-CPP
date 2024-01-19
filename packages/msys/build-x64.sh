#!/bin/bash

TARGET_DIR="/r/"
BUILD_DIR="${TEMP}/redpandacpp-build"
PACKAGE_DIR="${TEMP}/RedPanda-CPP"
GCC_DIR="/mingw64"
PATH="${GCC_DIR}/bin:${PATH}"
QMAKE="${GCC_DIR}/qt5-static/bin/qmake"
NSIS="/d/Program Files (x86)/NSIS/bin/makensis.exe"
SOURCE_DIR=`pwd`
MINGW="/e/Workspaces/contributes/MinGW/MinGW64"
MINGW_NAME="MinGW64"

rm -rf  "${BUILD_DIR}"
test -z "${BUILD_DIR}" | mkdir "${BUILD_DIR}"
rm -rf  "${PACKAGE_DIR}"
mkdir "${PACKAGE_DIR}"

echo "Building..."
pushd .
cd "${BUILD_DIR}"
make distclean
"$QMAKE" PREFIX="${PACKAGE_DIR}" X86_64=ON -o Makefile "${SOURCE_DIR}\Red_Panda_Cpp.pro" -r -spec win32-g++  
make -j16
make install
popd

echo "Making no-compiler installer ..."
pushd .
cd "${PACKAGE_DIR}"

cp "${SOURCE_DIR}/platform/windows/qt.conf" .

cp "${SOURCE_DIR}/platform/windows/installer-scripts/lang.nsh" .
cp "${SOURCE_DIR}/platform/windows/installer-scripts/redpanda-nocompiler.nsi" .

"${NSIS}" redpanda-nocompiler.nsi
rm -f lang.nsh
rm -f config.nsh
rm -f config32.nsh
rm -f config-clang.nsh
rm -f redpanda-nocompiler.nsi

SETUP_NAME=`ls *.Setup.exe`
PORTABLE_NAME=`echo $SETUP_NAME | sed 's/Setup.exe/Portable.7z/'`
mv "$SETUP_NAME" "${TARGET_DIR}"
popd

pushd .
cd "${TARGET_DIR}"
echo "Making no-compiler Portable Package..."
7z a -mmt8 -mx9  "${PORTABLE_NAME}" "${PACKAGE_DIR}"
popd

# we need reinstall config.nsh
pushd .
cd "${BUILD_DIR}"
make install
popd

echo "Making installer..."

pushd .
cd "${PACKAGE_DIR}"
cp  -a "${MINGW}" .
#rm -rf "${MINGW_NAME}/share/gcc-11.2.0"
#cp  -a "${SOURCE_DIR}/tools/gdb-scripts/gcc-11.2.0" "${MINGW_NAME}/share"

cp "${SOURCE_DIR}/platform/windows/installer-scripts/lang.nsh" .
cp "${SOURCE_DIR}/platform/windows/installer-scripts/redpanda-x64.nsi" .

"${NSIS}" redpanda-x64.nsi
rm -f lang.nsh
rm -f config.nsh
rm -f config32.nsh
rm -f config-clang.nsh
rm -f redpanda-x64.nsi

SETUP_NAME=`ls *.Setup.exe`
PORTABLE_NAME=`echo $SETUP_NAME | sed 's/Setup.exe/Portable.7z/'`
mv "$SETUP_NAME" "${TARGET_DIR}"

popd

pushd .

cd "${TARGET_DIR}"
echo "Making Portable Package..."
7z a -mmt8 -mx9  "${PORTABLE_NAME}" "${PACKAGE_DIR}"

echo "Clean up..."
rm -rf "${PACKAGE_DIR}"

popd

