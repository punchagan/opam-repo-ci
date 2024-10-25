(* SPDX-License-Identifier: Apache-2.0
 * Copyright (c) 2024 Puneeth Chaganti <punchagan@muse-amuse.in>, Shon Feder <shon.feder@gmail.com>, Tarides <contact@tarides.com>
 *)

open Opam_ci_check

let test_package_name_collision =
  let check p0 p1 expected =
    let test_name = Printf.sprintf "package_name_collision %s %s" p0 p1 in
    let got = Lint.Checks.package_name_collision p0 p1 in
    let test_fun () = Alcotest.(check bool) p0 expected got in
    (test_name, `Quick, test_fun)
  in
  [
    (* Detect collision modulo ('-' | '_' | '') *)
    check "foo_barbaz" "foo-bar-baz" true;
    (* No collision otherwise *)
    check "foo-barbaz" "eoocar_caz" false;
  ]

let collision_suite = ("Collision", test_package_name_collision)
let () = Alcotest.run "opam-ci-check" [ collision_suite ]
