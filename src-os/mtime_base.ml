(*---------------------------------------------------------------------------
   Copyright (c) 2015 Daniel C. Bünzli. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

(* Time scale conversion *)

let ns_to_s   = 1e-9
let us_to_s   = 1e-6
let ms_to_s   = 1e-3
let min_to_s  = 60.
let hour_to_s = 3600.
let day_to_s  = 86_400.
let year_to_s = 31_557_600.

let s_to_ns   = 1e9
let s_to_us   = 1e6
let s_to_ms   = 1e3
let s_to_min  = 1. /. min_to_s
let s_to_hour = 1. /. hour_to_s
let s_to_day  = 1. /. day_to_s
let s_to_year = 1. /. year_to_s

(* Pretty printing spans *)

let round x = floor (x +. 0.5)
let round_dfrac d x =               (* rounds [x] to the [d]th decimal digit *)
  if x -. (round x) = 0. then x else                     (* x is an integer. *)
  let m = 10. ** (float d) in                         (* m moves 10^-d to 1. *)
  (floor ((x *. m) +. 0.5)) /. m

let pp_span_s ppf span =
  let m = abs_float span in
  if m < ms_to_s then
    (* m < 1ms, if <  100us, print us with 3 frac digit w.o. trailing zeros
                if >= 100us, print us without frac digit *)
    let us = span /. us_to_s in
    let us = if abs_float us < 100. then round_dfrac 3 us else round us in
    if abs_float us >= 1000. then Format.fprintf ppf "%gms" (copysign 1. us)else
    Format.fprintf ppf "%gus" us
  else if m < 1. then
    (* m < 1s, if <  100ms, print ms with 3 frac digit w.o. trailing zeros
               if >= 100ms, print ms without frac digit *)
    let ms = span /. ms_to_s in
    let ms = if abs_float ms < 100. then round_dfrac 3 ms else round ms in
    if abs_float ms >= 1000. then Format.fprintf ppf "%gs" (copysign 1. ms) else
    Format.fprintf ppf "%gms" ms
  else if m < min_to_s then
    (* m < 1min, print [s] with 3 frac digit w.o. trailing zeros *)
    let s = round_dfrac 3 span in
    if abs_float s >= 60. then Format.fprintf ppf "%gmin" (copysign 1. s) else
    Format.fprintf ppf "%gs" s
  else
  (* m >= 1min
     From here on we show the two (or one if the second is zero) largest
     significant units and no longer care about rounding the lowest unit,
     we just truncate. *)
  if m < hour_to_s then
    let m, rem = truncate (span /. min_to_s), mod_float span min_to_s in
    let s = truncate rem in
    if s = 0 then Format.fprintf ppf "%dmin" m else
    Format.fprintf ppf "%dmin%ds" m (abs s)
  else if m < day_to_s then
    let h, rem = truncate (span /. hour_to_s), mod_float span hour_to_s in
    let m = truncate (rem /. min_to_s) in
    if m = 0 then Format.fprintf ppf "%dh" h else
    Format.fprintf ppf "%dh%dmin" h (abs m)
  else if m < year_to_s then
    let d, rem = truncate (span /. day_to_s), mod_float span day_to_s in
    let h = truncate (rem /. hour_to_s) in
    if h = 0 then Format.fprintf ppf "%dd" d else
    Format.fprintf ppf "%dd%dh" d (abs h)
  else
  let y, rem = truncate (span /. year_to_s), mod_float span year_to_s in
  let d = truncate (rem /. day_to_s) in
  if d = 0 then Format.fprintf ppf "%da" y else
  Format.fprintf ppf "%da%dd" y (abs d)

(*---------------------------------------------------------------------------
   Copyright (c) 2015 Daniel C. Bünzli

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
