#!/bin/bash

DOT_CONFIG_DIR="/workdir/build/yocto-ampliphy-master-2026-05-14-01-pinned/bitbake-builds/yocto-ampliphy-pinned/build/tmp/work-shared/phyboard-pollux-imx8mp-3/kernel-build-artifacts"

pushd ${DOT_CONFIG_DIR}

set -x
cat .config | grep CONFIG_ARCH_MXC
cat .config | grep CONFIG_NET_VENDOR_STMICRO
cat .config | grep CONFIG_STMMAC_ETH
cat .config | grep CONFIG_STMMAC_PLATFORM
cat .config | grep CONFIG_DWMAC_IMX8
cat .config | grep CONFIG_PCS_XPCS
cat .config | grep CONFIG_PHYLINK
cat .config | grep CONFIG_NET=y
cat .config | grep CONFIG_INET=y
cat .config | grep CONFIG_IP_PNP=y
cat .config | grep CONFIG_IP_PNP_DHCP=y
cat .config | grep CONFIG_NETDEVICES
cat .config | grep CONFIG_ETHERNET
cat .config | grep CONFIG_NET_VENDOR_FREESCALE
cat .config | grep CONFIG_MII
cat .config | grep CONFIG_PHYLIB=y
cat .config | grep CONFIG_FEC
set +x

popd

