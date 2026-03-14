#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let teal   = rgb("#0D9488")
#let teal-d = rgb("#0F766E")
#let teal-l = rgb("#CCFBF1")
#let ink    = rgb("#0F172A")
#let muted  = rgb("#64748B")
#let white  = rgb("#FFFFFF")
#let light  = rgb("#F8FAFC")
#let gray-l = rgb("#F1F5F9")
#let gray-d = rgb("#475569")

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

I primarily work with systems programming languages including C, C++, Go, and
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

I chose it because it involves Linux subsystems and eBPF. While working on
Lunatik I always compared scenarios with eBPF because it exists to serve
a similar purpose for kernel: *scripting*.

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
  node((1,3), [Call `bpf_lunatik_run()` kfunc]),
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

=== Generic `bpf_lunatik_run()` Layer

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

This restricts them to specific program types such as BPF_PROG_TYPE_SCHED_CLS.

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
dynamic rules, is expressed. The two are complementary.

The `__sk_buff` is exposed to Lua as a `luatc_data` userdata:
```lua
pkt[i]           -- raw byte at offset i (skb->data)
pkt:len()        -- skb->len
pkt.mark         -- skb->mark           (r/w)
pkt.priority     -- skb->priority       (r/w)
pkt.tc_index     -- skb->tc_index       (r/w)
pkt.tc_classid   -- skb->tc_classid     (r/w)
pkt.protocol     -- skb->protocol       (r)
pkt.tstamp       -- skb->tstamp         (r/w)
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

Example Lua handler: *Multi field egress classification*

TC filters classify packets into HTB classes, but existing classifiers (u32, flower) 
can only match static L3/L4 fields. They cannot combine multiple fields with 
conditional logic. Operators are forced into this pattern:

```shell
iptables -t mangle -A POSTROUTING -p tcp --dport 443 -j MARK --set-mark 0x1
iptables -t mangle -A POSTROUTING -p udp --dport 53  -j MARK --set-mark 0x1
tc filter add dev eth0 parent 1:0 handle 0x1 fw classid 1:10
```

Problems with this:
- Requires iptables and tc: two subsystems to configure
- Port-based only, cannot combine complex logic of ANDs and ORs of port + protocol + packet size + DSCP
- Static, adding a new rule requires editing iptables and reloading
- IPv6 variable headers break u32 offset-based matching

This can be conveniently solved via a Lua policy handler.
```lua
-- qos.lua
local tc = require("tc")

local policy = {
    -- realtime: VoIP and gaming
    {
        match = function(p)
            return p.protocol == 0x0800          -- IPv4
               and p:ip_proto() == 17            -- UDP
               and p.len < 256                   -- small packet
               and (p:dscp() == 46               -- DSCP Expedited Forwarding
                    or p.priority >= 6)          -- SO_PRIORITY high
        end,
        classid = 0x00010010   -- 1:10 realtime
    },

    -- bulk: large TCP segments, likely file transfer or backup
    {
        match = function(p)
            return p.protocol == 0x0800
               and p:ip_proto() == 6             -- TCP
               and p.len > 1400                  -- near-MTU = bulk transfer
               and p.priority == 0               -- no special priority set
        end,
        classid = 0x00010030   -- 1:30 bulk
    },

    -- interactive: SSH, DNS
    {
        match = function(p)
            local dport = p:dst_port()
            return dport == 22                   -- SSH
                or dport == 53                   -- DNS
                or dport == 123                  -- NTP
        end,
        classid = 0x00010010   -- 1:10 realtime
    },
}

local function handler(pkt)
    for _, rule in ipairs(policy) do
        if rule.match(pkt) then
            pkt.tc_classid = rule.classid
            return tc.action.OK
        end
    end
    return tc.action.OK
end

tc.attach(handler)
```

=== eBPF Maps Module

To fully use the bpf ecosystem via Lunatik, another value addition would be
an *eBPF maps module for Lunatik*. This will allow Lunatik to have:

- *Stateful policies*: a Lua DNS handler writes `{ip -> classid}` to a map;
  the eBPF fast path reads it
- *Cross-binding composition*: `luaxdp` writes to a map that `luatc` reads,
  enabling pipelines that span subsystems
- *Operator visibility*: Lua scripts read kernel maps to inspect state without
  a separate userspace tool

```lua
local map = require("ebpf.map")

local flow_table = map.open_by_id(42)
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
- #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L2536")[`bpf_map_get_curr_or_next(u32 *id)`]

`bpf_map_get` will need the file descriptor which needs to be created via
a userspace process context. However `bpf_lunatik_run` is going to run on softirq
context. So we could utilize `bpf_map_get_curr_or_next` API.

This will require the map id to be passed.

==== eBPF Map Lifecycle

1. Creation
This design requires bpf maps to be created outside Lunatik, via userspace 
programs like `bpftool`. We can get the map ID once it is created.

2. Lookup and usage
The map ID can be used to lookup the pointer to map in the kernel.
- `open_by_id()` will return the map pointer and increase the reference counter of the map.
- `lookup(key)` on the map pointer will return the value stored in the map for the provided key. We can reuse `luadata` for the actual types.
- `update(key, data)` on the map pointer will update the map for the provided key with the given data.
- `delete(key)` on the map pointer will delete the key from the map.
- Once we have the pointer to `struct bpf_map`, we could call kernel ops helpers defined #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L106")[here] to do lookup, update, delete.

3. Cleanup
- `close()` will cleanup the map from Lua, and decrease the reference counter via #link("https://elixir.bootlin.com/linux/v6.19.2/source/include/linux/bpf.h#L2521")[`bpf_map_put(struct bpf_map *map)`]

#diagram(
  node-stroke: 1pt,
  spacing: (4em, 3em),

  // Userspace
  node((1,0), [Userspace\ (bpftool / libbpf)], corner-radius: 2pt),
  edge("-|>", label: [`bpf(BPF_MAP_CREATE)`]),

  // Kernel boundary — labeled node acting as a section header
  node((1,1), [Kernel BPF Subsystem\ `struct bpf_map`], corner-radius: 2pt),

  // Map access path into Lunatik
  edge((1,1), (0,2), "-|>", label: [`bpf_map_get_curr_or_next(id)`], label-side: right),
  node((0,2), [Lunatik Runtime\ `ebpf.map` module], corner-radius: 2pt),
  edge("-|>"),
  node((0,3), [Lua Policy Handler], corner-radius: 2pt),

  // Map access path into eBPF
  edge((1,1), (2,2), "-|>", label: [map fd / id], label-side: left),
  node((2,2), [eBPF Program\ (XDP / TC)], corner-radius: 2pt),
  edge("-|>"),
  node((2,3), [bpf_map_lookup_elem\ bpf_map_update_elem], corner-radius: 2pt),

  // Shared state at the bottom
  node((1,4), [Shared Policy State\ (ip → classid)], shape: diamond),
  edge((0,3), (1,4), "-|>", label: [update], label-side: right),
  edge((2,3), (1,4), "-|>", label: [lookup], label-side: left),
)


== Expected Results

At the end of this project the Lunatik ecosystem will gain:

- A reusable `bpf_lunatik_run()` abstraction layer
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

    [Community Bonding], [Study Lunatik internals, discuss architecture with mentors],
    [Week 1–3], [Implement core `bpf_lunatik_run()` infrastructure and refactor the
    existing `bpf_luaxdp_run()` implementation to use it],

    [Week 4-6],
    [Implement `luatc` binding and expose `__sk_buff` context to Lua.],
    [Week 7-8],
    [Implement eBPF maps Lua module and kernel map access wrappers.],
    [Week 9-10],
    [Benchmarks of TC eBPF + Lua.],
    [Week 11-12],
    [Polish, code cleanup, final evaluation.],
)

= Midterm Deliverables (After 5 Weeks)

By the midterm evaluation:

- Generic bpf_lunatik_run() layer implemented
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

Linux is increasingly adopting eBPF as the standard way to extend the
kernel safely. However, the BPF verifier limits the expressiveness of
policy logic.

Lua complements eBPF perfectly: it is lightweight, embeddable, and
expressive enough to implement the dynamic logic that eBPF cannot.

The proposed bpf_lunatik_run() abstraction layer bridges these two
systems.

Instead of building isolated bindings, this infrastructure allows
future Lunatik modules across multiple subsystems to reuse the same
mechanism, multiplying the scripting capabilities of the kernel.
