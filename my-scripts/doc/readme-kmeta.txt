base:
This is the completely unpatched, vanilla upstream Linux kernel code.
It contains no Yocto validation tweaks, no specific architecture abstractions, and no container optimizations.

standard/base:
This branch contains the baseline kernel choices enforced by the Yocto Project (like specific virtualization flags, cgroup support, and systemd tracking tools).

nopatch:

include ktypes/standard/standard.scc nopatch

# since the patches were alreay applied over the kernel sources, we tell it not to apply them again

nocfg

git clone https://git.yoctoproject.org/yocto-kernel-tools.git

force:

let's see if this works ;)

