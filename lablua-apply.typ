#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let teal-d = rgb("#0F766E")
#let ink    = rgb("#0F172A")
#let white  = rgb("#FFFFFF")
#let light  = rgb("#F8FAFC")

#set page(margin: 2.5cm)

#set text(
  font: "Libertinus Serif",
  size: 11pt
)

#show raw.where(block: false): it => box(
  fill: light,
  inset: (x: 4pt, y: 2pt),
  radius: 3pt,
  baseline: 2pt,
)[#text(size: 9.5pt, fill: teal-d)[#it]]

#show raw.where(block: true): it => block(
  fill: light,
  radius: 6pt,
  inset: 14pt,
  width: 100%,
)[#text(size: 9pt, fill: ink)[#it]]

#set heading(numbering: "1.")

#align(center)[
  #text(size: 28pt, weight: "bold")[Google Summer of Code 2026]

  #text(size: 20pt)[Proposal]
  #v(0.5cm)

  #text(size: 18pt)[LabLua]

  #text(size: 18pt)[Lunatik eBPF Abstraction Layer]
  #v(0.1cm)

  #text(size: 16pt)[Binding for Linux Traffic Control (TC) and eBPF Maps]

  #v(0.8cm)

  #text(size: 12pt)[
    Ashwani Kumar Kamal
  ]

  #v(1cm)

  Email: ashwanikamal.im421\@gmail.com \
  GitHub: https://github.com/sneaky-potato/
]

#pagebreak()

= Basics

#table(
  columns: (35%, 65%),
  [*Preferred Email*], [ashwanikamal.im421\@gmail.com],
  [*GitHub*], [https://github.com/sneaky-potato/],
  [*Matrix ID*], [\@sneaky-potato:matrix.org],
  [*Academic Background*], [I graduated from IIT Kharagpur in 2024, with
  Bachelor of Technology in Computer Science and Engineering],
  [*Time Commitments During GSoC*], [I can dedicate 30-35 hours per week to the project],
)

= Experience

== Programming Languages

I primarily work with languages including C, C++, Go, and
Lua. I also use Bash for scripting.

== Tools for development

My development workflow uses Git, Linux-based environments,
and the Neovim editor. I also use some debugging tooling such as GDB, strace,
ltrace, libbpf utilities, bpftool.

== Lua Experience

I got introduced to Lua via Neovim configuration and basic scripting.
I contributed to Lunatik through which I got the major experience of
Lua and Lua C API. It helped me understand how Lua fits as an
embeddable language.

== Software Development Experience

I work as a Software Engineer at *Schlumberger* where I build backend
services and internal tools used in production systems. My work involves
designing microservices, optimizing database access patterns, and
improving the reliability and performance of distributed systems.

Recently, I led the migration of over 1 million customer records to
separate sensitive personally identifiable information (PII) from
operational data, improving data isolation and security. I also optimized
identity lookup queries using improved SQL joins and Redis caching,
reducing P95 request latency by approximately 40%.

I regularly collaborate with other engineers using Git-based workflows
including pull requests, code reviews, and issue-driven development.
I am comfortable discussing trade-offs, iterating on reviews, and
maintaining documentation alongside code.

Prior to this role, I completed a software engineering internship at
*Piramal Retail Finance* where I built a prototype in house job
scheduler capable of handling more than 10,000 scheduled tasks per day
across multiple microservices.

== Previous Projects

Some technical projects I have built include:

- *Goof Programming Language* (Hobby project):

As an attempt to understand language runtimes, I wrote a compiler for a 
programming language Goof which is a stack-based, concatenative 
language inspired by Forth for x86\_64 architectures.

The compiler, emits x86\_64 assembly and produces statically linked ELF 
binaries for Linux. The project includes a lexer, parser, stack-based 
intermediate representation, type checking, and a runtime supporting 
control flow, recursion, and system calls.

- *Route Optimization Backend (Inter IIT Tech Meet)* (Competition): 
Developed backend services for a delivery route planning system used during 
the Inter IIT Tech Meet competition. The system exposed HTTP and gRPC APIs, used
RabbitMQ for asynchronous task processing, and was containerized with
Docker to enable reliable deployment.

These projects helped me develop strong experience working with
systems-level programming, distributed systems, and backend service
design.

== Open Source Contributions

I have been actively exploring and contributing to the Lunatik ecosystem,
which enables Lua scripting within the Linux kernel.

While studying the existing implementation of Lunatik modules, I worked
on improving the method dispatch mechanism used by Lua objects in the
kernel runtime. By replacing repeated table lookups with eager closure
wrapping, I reduced method call overhead from roughly 275ns to 128ns in
benchmark tests across one million iterations.

In addition to Lunatik, I have also contributed patches to the etcd
project, focusing on improving the correctness and determinism of the
robustness testing framework by removing redundant delete and compact
operations.

= GSoC

#table(
  columns: (50%, 50%),
  stroke: none,
  [*Participated in GSoC before?*], [No],
  [*Applied but not selected before?*], [No],
  [*Applied to other organizations this year?*], [No],
)

= Project

I have selected the project *Lunatik Binding for Linux Traffic Control (TC) and
eBPF Maps* which is from the idea list.

While working on Lunatik I always compared scenarios with eBPF because it
exists to serve a similar purpose for kernel: *scripting*.

I noticed while contributing to Lunatik that to run Lua callbacks from bpf programs
there was one hook `bpf_luaxdp_run` but it was tightly coupled to xdp
and that the abstraction layer was missing.

While doing the technical reading required for this project I realized how Lua
could be used as a high level abstraction to further increase the expressiveness
of eBPF programs.
 
== Selected Idea

This project builds on Lunatik's existing networking capabilities,
specifically the `luaxdp` module, and proposes a *generalized eBPF
integration layer*.

The motivation comes from studying Lunatik's current architecture and
realizing that the value of new bindings is *combinatory rather than
linear*. Each additional subsystem integrated with Lua multiplies the
scripting possibilities available to the kernel.

Therefore, instead of implementing a single new binding in isolation,
this project proposes building a reusable infrastructure layer that
future bindings can use.

== Project Description

=== The Problem

eBPF has become the dominant mechanism for extending the Linux kernel at
runtime. It is fast, safe, and verifier-enforced. However, the verifier
also limits expressiveness and complex logic such as:

- dynamic string matching
- pattern-based rules
- dynamic policy tables
- hot-swappable logic

Lua provides a convenient way to express dynamic policies that are difficult to
encode within the verifier constraints of eBPF. It is small, embeddable, and designed
to act as a scripting layer that extends a host system without replacing
its core architecture.

=== Design Philosophy

This project follows a simple design pattern:

- *eBPF defines structure and safe hooks*
- *Lua implements dynamic policy logic*

The idea is to allow eBPF programs to delegate complex decisions to
Lua handlers inside Lunatik.

The architecture looks like this:

#import fletcher.shapes: diamond

#diagram(
  node-stroke: 1pt,
  spacing: (4em, 3em),

  node((1,0), [Packet arrives at NIC], corner-radius: 2pt, extrude: (0,3)),
  edge("-|>"),
  node((1,1), [TC / XDP Hook]),
  edge("-|>"),
  node((1,2), [eBPF Program]),
  edge("-|>"),
  node((1,3), [Call `lunatik_bpf_run()` kfunc]),
  edge("-|>"),
  node((1,4), [Lunatik Runtime]),
  edge("-|>"),
  node((1,5), [Lua Handler executes]),
  edge("-|>"),

  node((1,6), [Packet action?], shape: diamond),

  edge((1,6), (0,6), "-|>", label: [Drop], label-side: right),
  node((0,6), [Packet Dropped], corner-radius: 2pt),

  edge((1,6), (2,6), "-|>", label: [Pass], label-side: left),
  node((2,6), [Packet Forwarded], corner-radius: 2pt),
)


The Lua handler evaluates policy and returns a verdict, after which
execution continues inside the eBPF program.

Presently `luaxdp` implements this pattern but it is *tightly coupled to XDP*.
The kfunc `bpf_luaxdp_run()` is registered only for `BPF_PROG_TYPE_XDP` and 
receives an `xdp_md` context. 

This project aims to generalize that design.

== Core Components

=== Generic `lunatik_bpf_run()` Layer

Since eBPF programs cannot call arbitrary kernel functions, the Linux kernel
provides kfuncs as a mechanism for exposing functionality to BPF programs. 
These functions are registered with the BPF subsystem using BTF-based kfunc 
registration, which allows the verifier to enforce safety constraints.

The eBPF docs mention a list of kfuncs here: https://docs.ebpf.io/linux/kfuncs/,
This could provide with inspiration for future kfunc support by Lunatik.


==== Kfunc registration

```c
__bpf_kfunc int bpf_luaxdp_run(struct xdp_md *ctx, ...);
__bpf_kfunc int bpf_luatc_run(struct __sk_buff *skb, ...);
```

The functions are then registered with the BPF subsystem.

```c
BTF_KFUNCS_START(bpf_luatc_set)
BTF_ID_FLAGS(func, bpf_luatc_run)
BTF_KFUNCS_END(bpf_luatc_set)
```

Finally, during module initialization, the kfunc set is registered with the kernel for the relevant BPF program type:
```c
register_btf_kfunc_id_set(
    BPF_PROG_TYPE_SCHED_CLS,
    &bpf_luatc_kfunc_set
);
```

This restricts them to specific program types such as `BPF_PROG_TYPE_SCHED_CLS`.

==== Generic interface

Shared internal function that any type-specific kfunc can call:

```c
typedef int (*lunatik_bpf_cb)(lua_State *L, void *ctx);

int lunatik_bpf_run(const char *runtime_name, lunatik_bpf_cb push_ctx, void *ctx);
```

This function:
1. Looks up the named Lunatik runtime
2. Calls `push_ctx(L, ctx)` to push the context onto the Lua stack as a typed userdata
3. Invokes the registered Lua handler
4. Reads and returns the verdict

Type-specific kfuncs then become thin wrappers:

```c
// bpf_luaxdp_run will get refactored, behaviour unchanged
__bpf_kfunc int bpf_luaxdp_run(struct xdp_md *ctx, ...)
{
    return lunatik_bpf_run(runtime, luaxdp_push_ctx, ctx);
}

// bpf_luatc_run will be a new addition
__bpf_kfunc int bpf_luatc_run(struct __sk_buff *skb, ...)
{
    return lunatik_bpf_run(runtime, luatc_push_ctx, skb);
}
```

The `runtime` parameter allows multiple Lua runtimes to coexist, enabling different 
TC classifiers to delegate processing to different Lua handlers.

Each kfunc is registered for its specific `bpf_prog_type` via
`BTF_KFUNCS_START` / `BTF_KFUNCS_END`, maintaining verifier safety.

=== Traffic Control Binding (luatc)

Traffic Control is the primary demonstration of the generic layer. TC operates
on `__sk_buff` and is the place in the kernel with several capabilities:

- `tc_classid`: direct assignment to HTB qdisc classes for traffic shaping
- `tstamp`: packet transmit timestamp for pacing
- `priority`, `tc_index`, `mark`: classification metadata

None of these are available at XDP. TC is where shaping decisions are made.
Lua is where complex policy logic: string matching, pattern tables,
dynamic rules, is expressed.

We can extend the recently merged `luaskb` module which provides an
abstraction to `__sk_buff` data structure:
```lua
skb.mark         -- skb->mark           (r/w)
skb.priority     -- skb->priority       (r/w)
skb.tc_index     -- skb->tc_index       (r/w)
skb.tc_classid   -- skb->tc_classid     (r/w)
skb.protocol     -- skb->protocol       (r)
skb.tstamp       -- skb->tstamp         (r/w)
```

```lua
local tc = require("tc")

tc.action.OK          -- TC_ACT_OK         = 0
tc.action.RECLASSIFY  -- TC_ACT_RECLASSIFY = 1
tc.action.SHOT        -- TC_ACT_SHOT       = 2
tc.action.PIPE        -- TC_ACT_PIPE       = 3
tc.action.STOLEN      -- TC_ACT_STOLEN     = 4
tc.action.REDIRECT    -- TC_ACT_REDIRECT   = 7

tc.attach(handler)    -- register Lua callback
tc.detach()           -- unregister
```

=== eBPF Maps Module

To fully use the bpf ecosystem via Lunatik, we need access to shared kernel
state. Hence support for *eBPF maps module for Lunatik* is important,
this will allow Lunatik to have:

- *Stateful policies*: a Lua handler writes `{ip -> classid}` to a map;
  the eBPF fast path reads it
- *Cross-binding composition*: `luaxdp` writes to a map that `luatc` reads,
  enabling pipelines that span subsystems
- *Operator visibility*: Lua scripts read kernel maps to inspect state without
  a separate userspace tool

```lua
local map = require("ebpf.map")

local flow_table = map.open("/sys/fs/bpf/flow_cache")
local classid = flow_table:lookup(dst_ip)
flow_table:update(src_ip, new_classid)
flow_table:delete(stale_ip)
```

eBPF maps are created via `bpf(BPF_MAP_CREATE, ...)` and accessed via
`bpf_map_lookup_elem`, `bpf_map_update_elem`, and `bpf_map_delete_elem` helpers.
We want to access these via kernel's internal map API without going through syscall
interface.

The following APIs are exposed by kernel to use:
- All userspace calls (through libbpf) go through #link("https://elixir.bootlin.com/linux/v6.19.2/source/kernel/bpf/syscall.c#L6272")[`SYSCALL_DEFINE3()`]
- #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L2487")[`bpf_map_get(u32 ufd)`]
- #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L2488")[`bpf_map_get_with_uref(u32 ufd)`]

`bpf_map_get` will need the file descriptor which needs to be created via
a process context.

==== Map Creation
This design requires bpf maps to be created outside Lunatik, via userspace 
programs like `bpftool`.

```
bpftool map create /sys/fs/bpf/flow_cache type hash key 4 value 4 entries 128 name flow_cache
```

==== Map Lookup and usage
Map resolution happens once during script initialization via open(path), which
runs in process context inside `driver:write()`. The resolved `struct bpf_map*` is
stored in a Lua userdata and reused by all subsequent lookup/update/delete
calls. These are safe to call from softirq. 

bpffs intentionally blocks `filp_open` on pinned objects.
Instead we use `kern_path` to resolve the dentry without triggering the open
handler, then read `inode->i_private` directly where bpffs stores the `struct bpf_map*`. 

This has been verified via a kernel module POC.

```c
static int luabpf_map_open(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    struct path kpath;
    struct bpf_map *map;
    struct bpf_map **udata;
    int err;

    err = kern_path(path, LOOKUP_FOLLOW, &kpath);
    if (err)
        return luaL_error(L, "kern_path failed: %d", err);

    map = d_inode(kpath.dentry)->i_private;
    path_put(&kpath);

    if (!map || IS_ERR(map))
        return luaL_error(L, "not a valid bpf map path");

    bpf_map_inc(map); // increase reference counter

    udata = lua_newuserdata(L, sizeof(struct bpf_map *));
    *udata = map;
    luaL_setmetatable(L, "bpf.map");
    return 1;
}
```

- `lookup(key)` on the map pointer will return the value stored in the map for the provided key. We can reuse `luadata` for the actual types.
- `update(key, data)` on the map pointer will update the map for the provided key with the given data.
- `delete(key)` on the map pointer will delete the key from the map.
- Once we have the pointer to `struct bpf_map`, we could call kernel ops helpers defined #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L106")[here] to do lookup, update, delete.

==== Cleanup
- `close()` will cleanup the map from Lua, and decrease the reference counter via #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L2521")[`bpf_map_put(struct bpf_map *map)`]

#diagram(
  node-stroke: 1pt,
  spacing: (5em, 3em),

  node((0,0), [Userspace\ (`bin/lunatik`)], corner-radius: 2pt),
  node((1,0), [Userspace\ (`bpftool`)], corner-radius: 2pt),

  node((0,1), [`driver:write()`\ process context], corner-radius: 2pt),
  node((1,2), [bpffs\ `/sys/fs/bpf/*`], corner-radius: 2pt),

  node((0,2), [Lunatik Runtime\ `ebpf.map` module\ `map*` in Lua userdata], corner-radius: 2pt),
  node((2,3), [eBPF Program\ (TC / XDP)], corner-radius: 2pt),

  node((0,3), [Lua Policy Handler\ (softirq)], corner-radius: 2pt),

  node((1,4), [Shared Policy State\ (`ip -> classid`)], corner-radius: 4pt),

  edge((0,0), (0,1), "-|>", label: [`/dev/lunatik`], label-side: right),

  edge((1,0), (1,2), "-|>", label: [pinned], label-side: left),

  edge((0,1), (0,2), "-|>", label: [`lunatik_newruntime()`], label-side: right),

  edge((0,2), (1,2), "-|>"),

  edge((0,2), (0,3), "-|>", label: [`tc.attach(handler)`], label-side: right),

  edge((2,3), (0,3), "-|>", label: [`lunatik_bpf_run()`], label-side: right),

  edge((0,3), (1,4), "-|>", label: [`map->ops->map_update_elem`], label-side: right),

  edge((2,3), (1,4), "-|>"),
)

=== First Packet Classification

1. Setup TC
```shell
tc qdisc del dev eth0 root 2>/dev/null
tc qdisc add dev eth0 root handle 1: htb default 30

tc class add dev eth0 parent 1: classid 1:10 htb rate 20mbit  # realtime
tc class add dev eth0 parent 1: classid 1:20 htb rate 10mbit  # streaming
tc class add dev eth0 parent 1: classid 1:30 htb rate 5mbit   # bulk/default

tc filter add dev eth0 ingress bpf da obj tc.bpf.o sec classifier
```

2. eBPF program
```c
extern int bpf_luatc_run(char *key, size_t key__sz, struct __sk_buff *skb, void *arg, size_t arg__sz) __ksym;

SEC("tc")
int tls_classifier(struct __sk_buff *skb)
{
    struct flow_key key = extract_key(skb);
    // key could be made from src_ip, dst_ip, src_port, dst_port, ip_proto
    // We could also timestamp the cache entried to handle TCP port reuse.

    __u32 *classid = bpf_map_lookup_elem(&flow_cache, &key);
    if (classid) {
        skb->tc_classid = *classid;
        return TC_ACT_OK;
    }

    // only invoke Lua if this looks like a TLS ClientHello
    if (!is_tls_client_hello(skb))
        return TC_ACT_OK;

    return bpf_luatc_run(runtime, sizeof(runtime), skb, NULL, 0);
}
```

3. Lua policy handler
```lua
local tc  = require("tc")
local map = require("ebpf.map")

local cache = map.open_by_id(FLOW_CACHE_ID)

local policy = {
    ["netflix%.com$"]       = 0x00010030,  -- bulk
    ["meet%.google%.com$"]  = 0x00010010,  -- realtime
    ["%.zoom%.us$"]         = 0x00010010,  -- realtime
    ["%.backup%.internal$"] = 0x00010040,  -- background
}

local function parse_sni(p)
    -- get sni from the packet
end

local function is_tls_hello(p)
    -- check if the packet is TLS hello
end

local function handler(p)
    if not is_tls_hello(p) then return tc.action.OK end

    local sni = parse_sni(p)
    if not sni then return tc.action.OK end

    for pattern, classid in pairs(policy) do
        if sni:match(pattern) then
            cache:update(p:flow_key(), classid)
            p.tc_classid = classid
            return tc.action.OK
        end
    end

    return tc.action.OK
end

tc.attach(handler)
```

== Benchmarks and Evaluation

I have tried writing a TC implementation similar to XDP in
`sneaky-potato/luatc` branch of the project. Link #link("https://github.com/luainkernel/lunatik/tree/sneaky-potato/luatc")[here]

I tested two scenarios: pure eBPF program emitting `TC_ACT_OK`
for each packet and one eBPF program calling `bpf_tc_run` which
returns `tc.action.OK` for each packet.

I attached the following kprobe to measure latency.

```
sudo bpftrace -e '
kprobe:tcf_classify { @start[tid] = nsecs; }
kretprobe:tcf_classify {
    if (@start[tid]) {
        @lat = hist(nsecs - @start[tid]);
        delete(@start[tid]);
    }
}'
```

The results:
Pure eBPF:
- p50: ~3µs
- p95: ~6µs
- p99: ~20µ

eBPF + Lua TC:
- p50: ~6µs
- p95: ~12µs
- p99: ~40µ

Pure eBPF path
```
@lat:
[128, 256)            36 |                                               |
[256, 512)           125 |@@                                             |
[512, 1K)            251 |@@@@@                                          |
[1K, 2K)             797 |@@@@@@@@@@@@@@@@                               |
[2K, 4K)            2500 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[4K, 8K)            1737 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@           |
[8K, 16K)            255 |@@@@@                                          |
[16K, 32K)            60 |@                                              |
[32K, 64K)            20 |                                               |
```

eBPF classifier calling `bpf_luatc_run`
```
@lat:
[512, 1K)              8 |                                               |
[1K, 2K)             118 |@@                                             |
[2K, 4K)             270 |@@@@@@                                         |
[4K, 8K)            2216 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[8K, 16K)           1655 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@         |
[16K, 32K)           278 |@@@@@@                                         |
[32K, 64K)            13 |                                               |
[64K, 128K)            1 |                                               |
```

This hints to use Lua only when required, on slow paths.


== Expected Results

At the end of this project the Lunatik ecosystem will gain:

- A reusable `lunatik_bpf_run()` abstraction layer
- A new luatc binding for Traffic Control
- A Lua module for interacting with eBPF maps
- Documentation and working examples demonstrating the system

This will significantly expand Lunatik's ability to script kernel
behavior using Lua.

= Project Timeline

#table(
  columns: (26%, 74%),
  stroke: (paint: rgb("#E2E8F0"), thickness: 0.8pt),
  fill: (_, row) => if calc.odd(row) { light } else { white },
  inset: (x: 8pt, y: 7pt),

  table.header(
    table.cell(fill: teal-d)[#text(fill: white, weight: "bold")[Period]],
    table.cell(fill: teal-d)[#text(fill: white, weight: "bold")[Milestones]],
  ),

    [Community Bonding], [Agree on the lunatik_bpf_run callback interface with mentors, set up a test VM with BTF-enabled kernel],
    [Week 1–2], [Implement core `lunatik_bpf_run()` infrastructure and refactor the
    existing `bpf_luaxdp_run()` implementation to use it],
    [Week 3-5],
    [Implement `luatc` binding and expose `__sk_buff` context to Lua.],
    [Week 6-9],
    [Implement eBPF maps Lua module and kernel map access wrappers.],
    [Week 10-11],
    [Demo scripts and benchmarks of TC eBPF + Lua.],
    [Week 12],
    [Polish, code cleanup, final evaluation.],
)

= Midterm Deliverables (After 5 Weeks)

By the midterm evaluation:

- Generic lunatik_bpf_run() layer implemented
- bpf_luaxdp_run() refactored to use the new infrastructure
- Basic luatc binding implemented
- Lua handlers capable of interacting with TC packet context
- Initial demonstration scripts completed

= Final Deliverables

At the end of the project:

- Fully functional luatc module
- eBPF maps Lua API
- Examples and documentation

= Why This Project

I have always been interested in how computers works and how we can
tweak certain parts to get our job done. I find Lunatik very
interesting in the sense that it tries to achieve something bold:
kernel scripting with a high level language.

Lunatik helped me understand how Lua is actually a glue language
for already running systems. It is lightweight, embeddable, and
expressive enough to implement the dynamic logic.

Instead of building isolated bindings, the proposed infrastructure allows
future Lunatik modules across multiple subsystems to reuse the same
mechanism, multiplying the scripting capabilities of the kernel.
