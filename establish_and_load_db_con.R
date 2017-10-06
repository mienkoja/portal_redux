establish_and_load_db_con <- function(){
  if (!identical(find(what = "con"), ".GlobalEnv")) {
    con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                          dbname = Sys.getenv("OLIVER_REPLICA_DBNAME"),
                          host = Sys.getenv("OLIVER_REPLICA_HOST"), 
                          port = Sys.getenv("OLIVER_REPLICA_PORT"), 
                          user = Sys.getenv("OLIVER_REPLICA_USER"),
                          password = Sys.getenv("OLIVER_REPLICA_PASSWORD"))
    assign("con", con, envir = .GlobalEnv)
  } else {
    remove(con)
    con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                          dbname = Sys.getenv("OLIVER_REPLICA_DBNAME"),
                          host = Sys.getenv("OLIVER_REPLICA_HOST"), 
                          port = Sys.getenv("OLIVER_REPLICA_PORT"), 
                          user = Sys.getenv("OLIVER_REPLICA_USER"),
                          password = Sys.getenv("OLIVER_REPLICA_PASSWORD"))
    assign("con", con, envir = .GlobalEnv)
  }
}