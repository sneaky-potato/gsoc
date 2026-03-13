#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(margin: 2.5cm)

#set text(
  font: "Libertinus Serif",
  size: 11pt
)

#set heading(numbering: "1.")

#align(center)[
  #text(size: 28pt, weight: "bold")[Google Summer of Code Proposal]

  #v(1cm)

  #text(size: 18pt)[Lunatik eBPF Abstraction Layer]

  #v(0.8cm)

  #text(size: 12pt)[
    Ashwani Kumar Kamal \
    Google Summer of Code 2026
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
  [*Time Commitments During GSoC*], [no time],
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

As an attempt to understand language runtimes, I wrote a compiler for my
a programming language Goof which is a stack-based, concatenative 
language inspired by Forth for x86\_64 architectures. I have to bootstrap
the compiler yet.

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

Through this project I want to justify the use of Lua through Lunatik, even
though eBPF exists for the kernel.

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

Lua solves exactly this problem. It is small, embeddable, and designed
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
  node((1,3), [Call `bpf_lunatik_run()`]),
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

== Core Components

=== 1. Generic `bpf_lunatik_run()` Layer

The main infrastructure component is a reusable kernel function that
invokes Lua handlers from eBPF contexts.

Example interface:

```c
typedef int (*lunatik_bpf_cb)(lua_State *L, void *ctx);

int lunatik_bpf_run(const char *runtime_name, lunatik_bpf_cb push_ctx, void *ctx);
```

This function:

- Locates the Lunatik runtime
- Pushes the context into Lua as typed userdata
- Executes the Lua handler
- Returns the verdict back to the eBPF program

Specific bindings become thin wrappers:

```c
__bpf_kfunc int bpf_luaxdp_run(struct xdp_md *ctx)
{
    return lunatik_bpf_run(runtime, luaxdp_push_ctx, ctx);
}

__bpf_kfunc int bpf_luatc_run(struct __sk_buff *skb)
{
    return lunatik_bpf_run(runtime, luatc_push_ctx, skb);
}
```

=== 2. Traffic Control Binding (luatc)

Traffic Control will be implemented as the primary demonstration of the
generic abstraction layer.

The TC subsystem operates on __sk_buff packets and allows modification
of classification fields such as:

- mark
- priority
- tc_index
- tc_classid

Lua handlers can inspect packet data and assign shaping classes using
HTB qdisc configuration.

Example Lua handler:

```lua
local tc = require("tc")

local function handler(pkt)
    if pkt.len > 1400 then
        pkt.tc_classid = 0x00010030
    end
    return tc.action.OK
end

tc.attach(handler)
```

=== 3. eBPF Maps Module

To enable stateful policies, the project also proposes a Lunatik module
for interacting with eBPF maps.

Example Lua API:

```lua
local map = require("ebpf.map")

local flow_table = map.open(123)

local classid = flow_table:lookup(ip)
flow_table:update(ip, new_classid)
flow_table:delete(old_ip)
```

This enables:

- stateful packet policies
- cross-binding pipelines
- runtime inspection of kernel state

== Expected Results

At the end of this project the Lunatik ecosystem will gain:

- A reusable `bpf_lunatik_run()` abstraction layer
- A new luatc binding for Traffic Control
- A Lua module for interacting with eBPF maps

Documentation and working examples demonstrating the system

This will significantly expand Lunatik's ability to script kernel
behavior using Lua.

= Project Timeline

#table(
    columns: (25%, 75%),
    [Period], [Milestones],
    [Community Bonding], [Study Lunatik internals, discuss architecture with mentors],
    [Week 1–2], [Implement core bpf_lunatik_run() infrastructure and refactor the
    existing bpf_luaxdp_run() implementation to use it],

    [Week 3–4],
    [Implement luatc binding and expose __sk_buff context to Lua.],
    [Week 5],
    [Integrate TC Lua handler system and create example classifiers.],
    [Week 6–7],
    [Implement eBPF maps Lua module and kernel map access wrappers.],
    [Week 8–9],
    [Build advanced examples including DNS-based traffic shaping.],
    [Week 10–11],
    [Testing, debugging, and performance evaluation.],
    [Week 12],
    [Documentation, code cleanup, and preparation for final evaluation.],
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
