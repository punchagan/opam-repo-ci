(** [check ~host_os ~master ~packages commit] does various linting
    checks on the [packages] in [commit] relative to [master],
    for example relating to the format of [.opam] and [dune] files.
    This job is run locally. *)
val check :
  host_os:string ->
  master:Current_git.Commit.t Current.t ->
  packages:(OpamPackage.t * Analyse.Analysis.kind) list Current.t ->
  Current_git.Commit.t Current.t ->
  unit Current.t
