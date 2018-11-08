.onLoad <- function(libname, pkgname){
  setHook(packageEvent("rlang", "attach"),
          function(...) dotdot_first())
  setHook(packageEvent("data.table", "attach"),
          function(...) dotdot_first())
}
