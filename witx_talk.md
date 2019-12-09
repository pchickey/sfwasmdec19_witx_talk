---

---

# Evolving WASI with Code Generation

Pat Hickey
Fastly

These slides: `https://github.com/pchickey/sfwasmdec19_witx_talk`

---

# What is WASI?

It is a modular system interface for WebAssembly, focused on security and portability.

---

# Modular?

* WASI started out as a monolith! Just one big module named `wasi_unstable`.

* Ephemeral has split that functionality into 9 modules.

# Portable?

* WASI started out as a C header! "Whatever LLVM does" isn't portable.

* Now, it has a more friendly machine-readable spec, but still tied to C ABI.

---

# But WASI does work.

* WASI was simple enough that adoption was quick.

* We need to evolve WASI, and bring more languages & runtimes on board. These are at odds!

* We created the `witx` language, and describe what WASI is using `witx` specs.

---

# What is witx?

```scheme
(use "typenames.witx")

(module $wasi_snapshot_preview1
  ;;; Linear memory to be accessed by WASI functions that need it.
  (import "memory" (memory))

  ;;; Read command-line argument data.
  ;;; The size of the array should match that returned by `wasi_args_sizes_get()`
  (@interface func (export "args_get")
    (param $argv (@witx pointer (@witx pointer u8)))
    (param $argv_buf (@witx pointer u8))
    (result $error $errno)
  )
)
```


---

# witx Types:

The types are represented according to the C ABI (LLVM Wasm32) for now.

```scheme
;;; Timestamp in nanoseconds.
(typename $timestamp u64)

;;; Identifiers for clocks.
(typename $clockid
  (enum u32
    ;;; The clock measuring real time. Time value zero corresponds with
    ;;; 1970-01-01T00:00:00Z.
    $realtime
    ;;; The store-wide monotonic clock, which is defined as a clock measuring
    ;;; real time, whose value cannot be adjusted and which cannot have negative
    ;;; clock jumps. The epoch of this clock is undefined. The absolute time
    ;;; value of this clock therefore has no meaning.
    $monotonic
    ;;; The CPU-time clock associated with the current process.
    $process_cputime_id
    ;;; The CPU-time clock associated with the current thread.
    $thread_cputime_id
  )
)

```

---

# witx Types:

```scheme
;;; The contents of a $subscription.
(typename $subscription_u
  (union
    ;;; When type is `eventtype::clock`:
    (field $clock $subscription_clock)
    ;;; When type is `eventtype::fd_read` or `eventtype::fd_write`:
    (field $fd_readwrite $subscription_fd_readwrite)
  )
)

;;; Subscription to an event.
(typename $subscription
  (struct
    ;;; User-provided value that is attached to the subscription in the
    ;;; implementation and returned through `event::userdata`.
    (field $userdata $userdata)
    ;;; The type of the event to which to subscribe.
    (field $type $eventtype)
    ;;; The contents of the subscription.
    (field $u $subscription_u)
  )
)
```

---

# witx: the vision

* `.witx`: WebAssembly Interface Types + eXtensions
* Based on the WebAssembly Text (.wat) wherever possible: s-exprs, $idents, @attrs
* Eventaully just use Interface Types to describe interface. Implementations can
  pick whatever ABI they want.

---


# witx: the tool
## https://github.com/WebAssembly/WASI/tree/master/tools/witx

* Rust crate `witx` is the canonical implementation. Both a library and an
  executable.
* `witx` validates a specification
* `witx docs` emits Markdown of all the doc comments
* `witx polyfill` compares two specifications

---

# witx: the users

* `wasi-libc` was the first WASI implementation. Used for C/C++, and under the hood in Rust.
    * `wasi-headers` generates the `wasi/api.h` file!
    * This header was the original WASI spec, now it is just an implementation artifact.

* `wasi-common`, the Bytecode Alliance WASI runtime. used by Wasmtime and Lucet.
    * `wig` is a procedural macro that generates Rust type definitions for all WASI types.
    * Soon, wig will also emit boilerplate for functions, and polyfills.

---

# witx: the users

* `wasi` Rust crate: new bindings to WASI, free of wasi-libc dependency.
    * `generate-raw` crate generates Rust sources for the entire crate!

* `lucet-validate`: validates that all imports of a Wasm module are described
  by the given witx spec.

---

# witx: successful?

* witx has found inconsistiencies in the WASI spec itself.
* witx has saved some implementers some tedious work.

* However, all of the users use the Rust crate, and generate Rust or C.
* Other users: please come use witx! Use the crate, or implement your own.
* Give me feedback on what doesn't work.

---

# Thank You

## `https://github.com/WebAssembly/WASI`

Tons of people contributed to the material in this talk, including:

```text
Lin Clark
Sam Clegg
Alex Crichton
Yury Delendik
Frank Denis
Nick Fitzgerald
Adam Foltzer
Dan Gohman
Peter Huene
Jakub Konka
Marcin Mielniczuk
Till Schneidereit
```
