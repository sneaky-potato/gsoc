# Google Summer of Code

This repository will be used for any documents / notes related to my involvement
in the [Google Summer of Code 2026](https://summerofcode.withgoogle.com/) program

## LabLua

[LabLua](http://www.lua.inf.puc-rio.br/) is a laboratory dedicated to research about programming languages,
with emphasis on research involving the Lua language.

[Lunatik](https://github.com/luainkernel/lunatik) is a framework for scripting
the Linux kernel with Lua.

It is composed by the Lua interpreter modified to run in the kernel;
a device driver (written in Lua =)) and a command line tool to load and run 
scripts and manage runtime environments from the user space; 
a C API to load and run scripts and manage runtime environments from the kernel;
and Lua APIs for binding kernel facilities to Lua scripts. 

Lunatik has support for XDP, Netfilter but lacks support for TC and general eBPF
maps. The idea list mentions
[Lunatik Bindings for TC and eBPF maps](https://github.com/labluapucrio/gsoc?tab=readme-ov-file#lunatik-binding-for-linux-traffic-control-tc-and-ebpf-maps)
as a potential project. I would like to apply for the same.

I am writing a technical document [lunatik-eBPF-tech-doc.md](./lunatik-eBPF-tech-doc.md)
outlining the need for eBPF abstraction layer in Lunatik.

I will be documenting my proposal [here](./lablua-apply.md), work in progress right now.

