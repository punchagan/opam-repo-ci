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
let other_names = [ "pandoc"; "lwt"; "dune"; "zmq-lwt"; "dune-release" ]

let test_package_name_repeated_chars =
  let check pkg_nv expected =
    let test_name = Printf.sprintf "package_name_repeated_chars %s" pkg_nv in
    let pkg = OpamPackage.of_string pkg_nv in
    let got = Lint.TypoGuard.repeated_chars ~other_names pkg |> List.length in
    let test_fun () = Alcotest.(check int) pkg_nv expected got in
    (test_name, `Quick, test_fun)
  in
  [
    check "panndoc.0.1.0" 1;
    check "odoc.0.1.0" 0;
    check "lwtt.0.1.0" 1;
    check "ddune.0.1.0" 1;
  ]

let test_package_name_omitted_chars =
  let check pkg_nv expected =
    let test_name = Printf.sprintf "package_name_omitted_chars %s" pkg_nv in
    let pkg = OpamPackage.of_string pkg_nv in
    let got = Lint.TypoGuard.omitted_chars ~other_names pkg |> List.length in
    let test_fun () = Alcotest.(check int) pkg_nv expected got in
    (test_name, `Quick, test_fun)
  in
  [
    check "padoc.0.1.0" 1;
    check "odoc.0.1.0" 0;
    check "lt.0.1.0" 1;
    check "une.0.1.0" 1;
  ]

let test_package_name_swapped_chars =
  let check pkg_nv expected =
    let test_name = Printf.sprintf "package_name_swapped_chars %s" pkg_nv in
    let pkg = OpamPackage.of_string pkg_nv in
    let got = Lint.TypoGuard.swapped_chars ~other_names pkg |> List.length in
    let test_fun () = Alcotest.(check int) pkg_nv expected got in
    (test_name, `Quick, test_fun)
  in
  [
    check "pnadoc.0.1.0" 1;
    check "odoc.0.1.0" 0;
    check "ltw.0.1.0" 1;
    check "duen.0.1.0" 1;
  ]

let test_package_name_swapped_words =
  let check pkg_nv expected =
    let test_name = Printf.sprintf "package_name_swapped_words %s" pkg_nv in
    let pkg = OpamPackage.of_string pkg_nv in
    let got = Lint.TypoGuard.swapped_words ~other_names pkg |> List.length in
    let test_fun () = Alcotest.(check int) pkg_nv expected got in
    (test_name, `Quick, test_fun)
  in
  [
    check "lwt-zmq.0.1.0" 1;
    check "release_dune.0.1.0" 1;
    check "foo_bar.0.1.0" 0;
  ]

let typoguard_suite =
  ( "TypoGuard",
    [
      test_package_name_repeated_chars;
      test_package_name_omitted_chars;
      test_package_name_swapped_chars;
      test_package_name_swapped_words;
    ]
    |> List.concat )

(** Run the test suites *)
let () = Alcotest.run "opam-ci-check" [ collision_suite; typoguard_suite ]
