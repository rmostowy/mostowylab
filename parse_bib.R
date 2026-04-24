# parse_bib.R — robust BibTeX parser, no external packages required.

`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && nchar(a[1]) > 0) a[1] else b

parse_bib <- function(path) {
  raw <- paste(readLines(path, warn = FALSE), collapse = "\n")
  
  # Split on entry boundaries (newline before @)
  parts <- strsplit(raw, "\n(?=@)", perl = TRUE)[[1]]
  parts <- parts[grepl("^\\s*@[A-Za-z]", parts)]
  
  lapply(parts, parse_entry)
}

parse_entry <- function(txt) {
  txt <- trimws(txt)
  
  # Type: @article, @inproceedings, etc.
  type_m <- regmatches(txt, regexpr("^@([A-Za-z]+)", txt, perl = TRUE))
  type <- if (length(type_m)) tolower(sub("^@", "", type_m)) else "misc"
  
  # Key: @article{KEY,
  key_m <- regmatches(txt, regexpr("@[A-Za-z]+\\{([^,]+)", txt, perl = TRUE))
  key <- if (length(key_m)) trimws(sub("@[A-Za-z]+\\{", "", key_m)) else ""
  
  # Inner content between first { and matching }
  open <- regexpr("\\{", txt)[1]
  chars <- strsplit(txt, "")[[1]]
  depth <- 0; end_pos <- length(chars)
  for (ci in seq(open, length(chars))) {
    if (chars[ci] == "{") depth <- depth + 1
    else if (chars[ci] == "}") {
      depth <- depth - 1
      if (depth == 0) { end_pos <- ci; break }
    }
  }
  inner <- paste(chars[(open+1):(end_pos-1)], collapse = "")
  
  # Extract fields: field = {value} or field = "value" or field = bare
  fields <- list(type = type, key = key)
  
  field_names <- c("title","author","journal","booktitle","year","volume",
                   "number","pages","doi","pmid","pmcid","url","month",
                   "publisher","issn","note","editor","address","series")
  
  for (fn in field_names) {
    # Pattern: fieldname = { ... }  (handles nested braces)
    pat <- paste0("(?i)\\b", fn, "\\s*=\\s*\\{")
    m <- regexpr(pat, inner, perl = TRUE)
    if (m[1] > 0) {
      start <- m[1] + attr(m, "match.length") - 1  # index of opening {
      ichars <- strsplit(inner, "")[[1]]
      depth2 <- 0; end2 <- length(ichars)
      for (ci2 in seq(start, length(ichars))) {
        if (ichars[ci2] == "{") depth2 <- depth2 + 1
        else if (ichars[ci2] == "}") {
          depth2 <- depth2 - 1
          if (depth2 == 0) { end2 <- ci2; break }
        }
      }
      val <- paste(ichars[(start+1):(end2-1)], collapse = "")
      fields[[fn]] <- clean_bib_val(val)
      next
    }
    
    # Pattern: fieldname = "value"
    pat2 <- paste0('(?i)\\b', fn, '\\s*=\\s*"([^"]*)"')
    m2 <- regmatches(inner, regexpr(pat2, inner, perl = TRUE))
    if (length(m2) > 0 && nchar(m2) > 0) {
      val2 <- sub(paste0('(?i)\\b', fn, '\\s*=\\s*"'), "", m2, perl = TRUE)
      val2 <- sub('"$', "", val2)
      fields[[fn]] <- clean_bib_val(val2)
      next
    }
    
    # Bare value (e.g. month = jun) — only for simple word tokens
    pat3 <- paste0("(?i)\\b", fn, "\\s*=\\s*([a-zA-Z0-9]+)\\s*[,}]")
    m3 <- regmatches(inner, regexpr(pat3, inner, perl = TRUE))
    if (length(m3) > 0 && nchar(m3) > 0) {
      val3 <- sub(paste0("(?i)\\b", fn, "\\s*=\\s*"), "", m3, perl = TRUE)
      val3 <- sub("[,}]$", "", val3)
      fields[[fn]] <- trimws(val3)
    }
  }
  
  fields
}

clean_bib_val <- function(s) {
  # Specific LaTeX accent sequences (order matters — do specific before generic)
  s <- gsub("\\{\\\\'e\\}", "\u00e9", s)
  s <- gsub("\\{\\\\'E\\}", "\u00c9", s)
  s <- gsub("\\{\\\\'a\\}", "\u00e1", s)
  s <- gsub("\\{\\\\'o\\}", "\u00f3", s)
  s <- gsub("\\{\\\\'u\\}", "\u00fa", s)
  s <- gsub("\\{\\\\'c\\}", "\u0107", s)
  s <- gsub("\\{\\\\'n\\}", "\u0144", s)
  s <- gsub("\\{\\\\'s\\}", "\u015b", s)
  s <- gsub("\\{\\\\'z\\}", "\u017a", s)
  s <- gsub("\\{\\\\\"a\\}", "\u00e4", s)
  s <- gsub("\\{\\\\\"o\\}", "\u00f6", s)
  s <- gsub("\\{\\\\\"u\\}", "\u00fc", s)
  s <- gsub("\\{\\\\\"A\\}", "\u00c4", s)
  s <- gsub("\\{\\\\\"O\\}", "\u00d6", s)
  s <- gsub("\\{\\\\\"U\\}", "\u00dc", s)
  s <- gsub("\\{\\\\v\\{[^}]*\\}\\}", "", s)  # remove unknown \v{x}
  s <- gsub("\\{\\\\`[a-zA-Z]\\}", "", s)
  s <- gsub("\\{\\\\~[a-zA-Z]\\}", "", s)
  s <- gsub("\\{\\\\\\^[a-zA-Z]\\}", "", s)
  # Polish ł / Ł
  s <- gsub("\\{\\\\l\\}", "\u0142", s)
  s <- gsub("\\{\\\\L\\}", "\u0141", s)
  s <- gsub("\\\\l\\b", "\u0142", s)
  s <- gsub("\\\\L\\b", "\u0141", s)
  # \. (dot accent — ż)
  s <- gsub("\\{\\\\.z\\}", "\u017c", s)
  s <- gsub("\\{\\\\.Z\\}", "\u017b", s)
  # Czech ě / ř
  s <- gsub("\\{\\\\v e\\}", "\u011b", s)
  s <- gsub("\\{\\\\v r\\}", "\u0159", s)
  # Remove remaining braces and backslash commands
  s <- gsub("\\\\&", "&", s)
  s <- gsub("\\{([^{}]*)\\}", "\\1", s)  # unwrap simple {text}
  s <- gsub("\\{|\\}", "", s)             # remove any remaining braces
  s <- gsub("\\\\[a-zA-Z]+\\s*", "", s)  # remove remaining LaTeX commands
  s <- gsub("\\\\.", "", s)
  s <- gsub("\\s+", " ", s)
  trimws(s)
}
