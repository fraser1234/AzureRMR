#' Miscellaneous utility functions
#'
#' @param lst A named list of objects.
#' @param name_fields The components of the objects in `lst`, to be used as names.
#' @param x For `is_url` and `is_empty`, An R object.
#' @param https_only For `is_url`, whether to allow only HTTPS URLs.
#'
#' @details
#' `named_list` extracts from each object in `lst`, the components named by `name_fields`. It then constructs names for `lst` from these components, separated by a `"/"`.
#'
#' @return
#' For `named_list`, the list that was passed in but with names. An empty input results in a _named list_ output: a list of length 0, with a `names` attribute.
#'
#' For `is_url`, whether the object appears to be a URL (is character of length 1, and starts with the string `"http"`). Optionally, restricts the check to HTTPS URLs only. For `is_empty`, whether the length of the object is zero (this includes the special case of `NULL`).
#'
#' @rdname utils
#' @export
named_list <- function(lst=NULL, name_fields="name")
{
    if(is_empty(lst))
        return(structure(list(), names=character(0)))

    lst_names <- sapply(name_fields, function(n) sapply(lst, `[[`, n))
    if(length(name_fields) > 1)
    {
        dim(lst_names) <- c(length(lst_names) / length(name_fields), length(name_fields))
        lst_names <- apply(lst_names, 1, function(nn) paste(nn, collapse="/"))
    }
    names(lst) <- lst_names
    dups <- duplicated(tolower(names(lst)))
    if(any(dups))
    {
        duped_names <- names(lst)[dups]
        warning("Some names are duplicated: ", paste(unique(duped_names), collapse=" "), call.=FALSE)
    }
    lst
}


# check if a string appears to be a http/https URL, optionally only https allowed
#' @rdname utils
#' @export
is_url <- function(x, https_only=FALSE)
{
    pat <- if(https_only) "^https://" else "^https?://"
    is.character(x) && length(x) == 1 && grepl(pat, x)
}


# TRUE for NULL and length-0 objects
#' @rdname utils
#' @export
is_empty <- function(x)
{
    length(x) == 0
}


# check that 1) all required names are present; 2) optional names may be present; 3) no other names are present
validate_object_names <- function(x, required, optional=character(0))
{
    valid <- all(required %in% x) && all(x %in% c(required, optional))
    if(!valid)
        stop("Invalid object names")
}


# handle different behaviour of file_path on Windows/Linux wrt trailing /
construct_path <- function(...)
{
    sub("/$", "", file.path(..., fsep="/"))
}
