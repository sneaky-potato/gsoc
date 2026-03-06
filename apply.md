## LabLua
- [Scheduler bindings for Lunatik](https://github.com/labluapucrio/gsoc?tab=readme-ov-file#lunatik-binding-for-sched-ext)
    - read `sched_ext` and support from kernel side
    - read how eBPF programs load schedulers to kernel
    - prepare architecture diagram from Lunatik

## FreeBSD
- [Port or reimplement udmabuf](https://wiki.freebsd.org/SummerOfCodeIdeas)
    - Linux API that allows userspace programs to create DMA-BUFs from user memory (through passing a memfd)
    - allowing the compositor to import this DMA-BUF directly instead of having to do an explicit GPU upload if just using shm.
    - Linux: udmabuf is a misc char device driver (drivers/dma-buf/udmabuf.c)
    - FreeBSD: what you will need to reimplement or port this device driver

## Debian
- NOT PROCEEDING: heavy project (350+ hours)
- [Linux livepatching](https://wiki.debian.org/SummerOfCode2026/Projects#SummerOfCode2026.2FApprovedProjects.2FLinuxLivePatching.Linux_Livepatching)
    - read on Debian packaging, linux livepatching
    - finish the linux-livepatching ITP bug (https://bugs.debian.org/1070494)

