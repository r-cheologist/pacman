#' Installs & Loads GitHub Packages 
#' 
#' Installs a GitHub package.  A wrapper for \code{\link[remotes]{install_github}}
#' which is the same as \code{\link[devtools]{install_github}}.
#' 
#' @param package Repository address(es) in the format 
#' \code{username/repo[/subdir][@@ref|#pull]}.  
#' Note that this must be a character string.
#' @param dependencies logical.  If \code{TRUE} necessary dependencies will be 
#' installed as well.
#' @param \ldots Additional parameters to pass to \code{\link[remotes]{install_github}}.
#' @keywords github install
#' @seealso \code{\link[remotes]{install_github}}
#' @export
#' @examples
#' \dontrun{
#' p_install_gh("trinker/pacman")
#' 
#' ## Package doesn't exist
#' p_install_gh("trinker/pacmanAwesomer")
#' }
p_install_gh <- function(package, dependencies = TRUE, ...){

    if (p_loaded(char = package)) {
        p_unload(char = package)
    }

    ## Download package
    out <- lapply(package, function(x) {
        tryCatch({
          remotes::install_github(x, dependencies = dependencies, upgrade = 'always', ...)
          TRUE
        },
        error = function(e) {
            # Possibly add a quiet parameter to mute this?
            message("Installation failed: ", paste(deparse(conditionCall(e)), collapse = " "), " : ", conditionMessage(e))
            FALSE
        }
        )
    })
    
    ## Check if package was installed & success notification.
    pack <- sapply(package, function(x) parse_git_repo(x)[["repo"]])

    ## Message for install status
    install_checks <- stats::setNames(unlist(out), pack)

    caps_check <- p_isinstalled(pack) == install_checks
    if (any(!caps_check)) {
        warning(paste0("The following may have incorrect capitalization specification:\n\n", 
            paste(names(caps_check)[!caps_check], collapse=", ")))
    }

    if(any(install_checks)){
        did_install <- paste(names(install_checks)[install_checks], collapse=", ")
        message(sprintf(
            "\nThe following packages were installed:\n%s", 
                did_install)
        )
    }
    if (any(!install_checks)){
        did_not_install <- paste(names(install_checks)[!install_checks], collapse=", ")
        message(sprintf(
            "\nThe following packages were not able to be installed:\n%s", 
                did_not_install)
        )
    }       
    return(invisible(install_checks))

}
