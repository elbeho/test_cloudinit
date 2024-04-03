#!/usr/bin/env bash

typeset -r me=$(basename $0)
typeset -r here=$(cd $(dirname $0); pwd )

#
# get the cloud-init image
#
IMG=jammy-server-cloudimg-amd64.img
URL_IMG=https://cloud-images.ubuntu.com/jammy/current/${IMG}
if [ ! -f "$here/img/$IMG" ]
then
    curl -D- -o "$IMG" "$URL_IMG"
    if [ $? != 0 ]
    then
        echo "[FATAL] Cannot get the image $IMG. Abort." >&2
        exit 1
    fi
fi
#
# and a data disc
#
if [ ! -f "$here/img/data.qcow2" ]
then
    qemu-img create -f qcow2 img/data.qcow2 10G
    if [ $? != 0 ]
    then
        echo "[FATAL] Cannot create the data disc. Abort." >&2
        exit 1
    fi
fi


cd data
#
# start the http server
#
if [0 = 1]
then
python3 -m http.server --directory .  >/dev/null 2>&1  &
fi


qemu-system-x86_64                                            \
    -net nic                                                  \
    -net user                                                 \
    -machine accel=kvm:tcg                                    \
    -cpu host                                                 \
    -m 512                                                    \
    -nographic                                                \
    -hda ../img/jammy-server-cloudimg-amd64.img               \
    -hdb ../img/data.qcow2                                    \
    -smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'

